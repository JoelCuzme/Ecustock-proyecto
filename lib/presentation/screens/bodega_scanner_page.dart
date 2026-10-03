import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:ecustock/core/services/native_permission_service.dart';
import 'package:ecustock/core/services/notification_service.dart';
import 'package:ecustock/data/models/product.dart';
import 'package:ecustock/data/repositories/product_repository.dart';

class BodegaScannerPage extends StatefulWidget {
  const BodegaScannerPage({super.key});

  @override
  State<BodegaScannerPage> createState() => _BodegaScannerPageState();
}

class _BodegaScannerPageState extends State<BodegaScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final ProductRepository _productRepository = ProductRepository();

  PermissionStatus _cameraStatus = PermissionStatus.denied;
  bool _manualMode = true;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isSaving = false;
  Product? _selectedProduct;
  String? _statusMessage;
  String _movement = 'egreso';

  @override
  void initState() {
    super.initState();
    _initializeCameraState();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _initializeCameraState() async {
    final status = await Permission.camera.status;
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraStatus = status;
      _manualMode = !status.isGranted;
      _isLoading = false;
    });
  }

  Future<void> _requestCameraPermission() async {
    setState(() => _isLoading = true);
    final status =
        await NativePermissionService.requestCameraPermission(context);
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraStatus = status;
      _manualMode = !status.isGranted;
      _isLoading = false;
    });

    if (status.isGranted) {
      _showStatus('Cámara lista para escaneo', const Color(0xFF10B981));
    } else {
      _showStatus('Modo manual activo', const Color(0xFFF59E0B));
    }
  }

  Future<void> _toggleFlash() async {
    await _scannerController.toggleTorch();
  }

  Future<void> _switchCamera() async {
    await _scannerController.switchCamera();
  }

  Future<void> _lookupProductByCode(String code) async {
    final cleanCode = code.trim();
    final isValid = RegExp(r'^\d{8,14}$').hasMatch(cleanCode);

    if (!isValid) {
      _showStatus('El código debe tener entre 8 y 14 dígitos.',
          const Color(0xFFEF4444));
      return;
    }

    if (_isSearching || _isSaving) return;
    setState(() => _isSearching = true);
    try {
      final product = await _productRepository.getProductByBarcode(cleanCode);
      if (!mounted) return;
      setState(() {
        _selectedProduct = product;
        _barcodeController.text = cleanCode;
      });
      _showStatus(
        'Producto encontrado en inventario',
        const Color(0xFF10B981),
      );
    } on DioException catch (error) {
      if (mounted) {
        _showStatus(
          _errorMessage(error),
          error.response?.statusCode == 404
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444),
        );
      }
    } catch (error) {
      if (mounted) {
        _showStatus(
          'No se pudo consultar el producto: $error',
          const Color(0xFFEF4444),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  String _errorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return error.message ?? 'No se pudo completar la operación.';
  }

  void _showStatus(String message, Color color) {
    setState(() => _statusMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _registerMovement(String type) async {
    if (_selectedProduct == null) {
      _showStatus(
          'Primero escanea o busca un producto.', const Color(0xFFEF4444));
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity <= 0) {
      _showStatus(
          'La cantidad debe ser mayor que cero.', const Color(0xFFEF4444));
      return;
    }

    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final updatedProduct = await _productRepository.registerStockMovement(
        productId: _selectedProduct!.id,
        type: type,
        quantity: quantity,
      );
      if (!mounted) return;

      setState(() {
        _selectedProduct = updatedProduct;
        _isSaving = false;
      });
      _showStatus(
        type == 'ingreso'
            ? 'Ingreso registrado correctamente.'
            : 'Egreso registrado correctamente.',
        const Color(0xFF10B981),
      );

      if (updatedProduct.stock <= updatedProduct.stockMinimo) {
        try {
          final permissionStatus = await Permission.notification.status;
          if (permissionStatus.isGranted) {
            await NotificationService.showInventoryAlert(
              productName: updatedProduct.nombre,
              stockActual: updatedProduct.stock,
              stockMinimo: updatedProduct.stockMinimo,
            );
          } else if (mounted) {
            _showStatus(
              'Alerta: ${updatedProduct.nombre} quedó en ${updatedProduct.stock} unidades. Límite mínimo: ${updatedProduct.stockMinimo}.',
              const Color(0xFFF59E0B),
            );
          }
        } catch (error) {
          if (mounted) {
            _showStatus(
              'Movimiento registrado, pero no se pudo enviar la alerta: $error',
              const Color(0xFFF59E0B),
            );
          }
        }
      }
    } on DioException catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showStatus(_errorMessage(error), const Color(0xFFEF4444));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showStatus(
          'No se pudo registrar el movimiento: $error',
          const Color(0xFFEF4444),
        );
      }
    }
  }

  Color _stockColor(int stock, int stockMinimo) {
    if (stock <= stockMinimo) {
      return const Color(0xFFEF4444);
    }
    if (stock <= stockMinimo + 5) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Escaneo de bodega',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Chip(
              label: Text('Bodega'),
              backgroundColor: Color(0xFFDBEAFE),
              labelStyle: TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Críticos',
                      value: '02',
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Activos',
                      value: '128',
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(15, 23, 42, 0.04),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF1E3A8A),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Escáner de producto',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_cameraStatus.isGranted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Disponible',
                              style: TextStyle(
                                color: Color(0xFF166534),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (!_manualMode && _cameraStatus.isGranted)
                      _buildScannerCard()
                    else
                      _buildManualInputCard(),
                    const SizedBox(height: 16),
                    if (_statusMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusMessage!,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedProduct != null) _buildProductCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerCard() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 280,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final rawValue = capture.barcodes.isNotEmpty
                        ? capture.barcodes.first.rawValue
                        : null;
                    if (rawValue != null &&
                        rawValue.trim().isNotEmpty &&
                        rawValue.trim() != _selectedProduct?.codigoBarras) {
                      _lookupProductByCode(rawValue);
                    }
                  },
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ScannerGuidePainter(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 18,
                  child: FloatingActionButton(
                    heroTag: 'flash-toggle',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    onPressed: _toggleFlash,
                    child: const Icon(Icons.flash_on_rounded),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  right: 18,
                  child: FloatingActionButton(
                    heroTag: 'camera-toggle',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    onPressed: _switchCamera,
                    child: const Icon(Icons.flip_camera_android_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _requestCameraPermission,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Revisar permiso'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManualInputCard() {
    return Column(
      children: [
        TextField(
          controller: _barcodeController,
          keyboardType: TextInputType.number,
          maxLength: 14,
          decoration: InputDecoration(
            labelText: 'Código de barras',
            hintText: 'Ej. 123456789012',
            prefixIcon: const Icon(Icons.numbers_rounded),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _isSearching
                    ? null
                    : () => _lookupProductByCode(_barcodeController.text),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Buscar producto'),
              ),
            ),
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: _requestCameraPermission,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Solicitar cámara'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_cameraStatus.isPermanentlyDenied || _cameraStatus.isRestricted)
          TextButton.icon(
            onPressed: () async {
              await openAppSettings();
            },
            icon: const Icon(Icons.settings_applications_rounded),
            label: const Text('Abrir ajustes del sistema'),
          ),
      ],
    );
  }

  Widget _buildProductCard() {
    final product = _selectedProduct!;
    final stockColor = _stockColor(product.stock, product.stockMinimo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Producto encontrado',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  product.codigoBarras,
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  icon: Icons.inventory_2_outlined,
                  label: 'Stock actual',
                  value: '${product.stock} uds',
                  tint: stockColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoPill(
                  icon: Icons.warning_amber_rounded,
                  label: 'Mínimo',
                  value: '${product.stockMinimo} uds',
                  tint: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Registrar movimiento',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'egreso',
                      label: Text('Egreso'),
                    ),
                    ButtonSegment<String>(
                      value: 'ingreso',
                      label: Text('Ingreso'),
                    ),
                  ],
                  selected: {_movement},
                  onSelectionChanged: (selection) {
                    setState(() => _movement = selection.first);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: 'Revisión de stock',
                  decoration: InputDecoration(
                    labelText: 'Motivo',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Revisión de stock',
                      child: Text('Revisión de stock'),
                    ),
                    DropdownMenuItem(
                      value: 'Venta',
                      child: Text('Venta'),
                    ),
                    DropdownMenuItem(
                      value: 'Pedido recibido',
                      child: Text('Pedido recibido'),
                    ),
                    DropdownMenuItem(
                      value: 'Ajuste de inventario',
                      child: Text('Ajuste de inventario'),
                    ),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      _isSaving ? null : () => _registerMovement(_movement),
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_movement == 'ingreso'
                      ? 'Registrar ingreso'
                      : 'Registrar egreso'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: tint),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: tint,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final rect = Rect.fromCenter(
      center: Offset(width / 2, height / 2 - 14),
      width: width * 0.72,
      height: height * 0.52,
    );

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final outerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    final overlayPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(22)));

    canvas.drawPath(overlayPath, outerPaint);

    final guide = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    canvas.drawRRect(guide, borderPaint);

    final scanLinePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final scanY = rect.top +
        (math.sin(DateTime.now().millisecondsSinceEpoch / 300) + 1) *
            rect.height /
            2;
    canvas.drawLine(
      Offset(rect.left + 12, scanY),
      Offset(rect.right - 12, scanY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
