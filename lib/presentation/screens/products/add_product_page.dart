import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ecustock/data/models/product.dart';
import 'package:ecustock/presentation/bloc/product_bloc.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(),
      child: const _AddProductView(),
    );
  }
}

class _AddProductView extends StatefulWidget {
  const _AddProductView();

  @override
  State<_AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<_AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _stockMinimoController = TextEditingController(text: '0');
  final _precioCostoController = TextEditingController();
  final _precioVentaController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _precioCostoController.dispose();
    _precioVentaController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = Product(
      id: 0,
      nombre: _nombreController.text.trim(),
      codigoBarras: _codigoController.text.trim(),
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      stockMinimo: int.tryParse(_stockMinimoController.text.trim()) ?? 0,
      precioCosto: double.tryParse(_precioCostoController.text.trim()) ?? 0,
      precioVenta: double.tryParse(_precioVentaController.text.trim()) ?? 0,
    );

    context.read<ProductBloc>().add(AddProduct(product));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF15803D),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
            ),
          );
          context.pop();
        }

        if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFB42318),
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nuevo producto')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completa los datos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Registra el producto en tu inventario.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card.outlined(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              hintText: 'Ej. Café molido 500 g',
                              helperText: 'Usa un nombre fácil de identificar.',
                              prefixIcon: Icon(Icons.sell_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final nombre = value?.trim() ?? '';
                              final characterCount = nombre.runes.length;
                              if (characterCount < 3 || characterCount > 100) {
                                return 'El nombre debe tener entre 3 y 100 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _codigoController,
                            decoration: const InputDecoration(
                              labelText: 'Código de barras',
                              hintText: 'Entre 8 y 14 dígitos',
                              helperText: 'Escanéalo o ingrésalo manualmente.',
                              prefixIcon: Icon(Icons.qr_code_2_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final codigo = value?.trim() ?? '';
                              if (!RegExp(r'^\d{8,14}$').hasMatch(codigo)) {
                                return 'Ingresa entre 8 y 14 dígitos.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock inicial',
                              hintText: '0',
                              helperText: 'Unidades disponibles actualmente.',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final stock = int.tryParse(value?.trim() ?? '');
                              if (stock == null || stock < 0) {
                                return 'Ingresa un entero mayor o igual a cero.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stockMinimoController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock mínimo',
                              hintText: '0',
                              helperText: 'Límite para identificar stock bajo.',
                              prefixIcon: Icon(Icons.warning_amber_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final stockMinimo = int.tryParse(
                                value?.trim() ?? '',
                              );
                              if (stockMinimo == null || stockMinimo < 0) {
                                return 'Ingresa un entero mayor o igual a cero.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _precioCostoController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Precio de costo',
                              hintText: '0.00',
                              helperText: 'Costo unitario de adquisición.',
                              prefixIcon: Icon(Icons.attach_money_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final price = double.tryParse(
                                value?.trim() ?? '',
                              );
                              if (price == null || price <= 0) {
                                return 'El precio de costo debe ser mayor que cero.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _precioVentaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Precio de venta',
                              hintText: '0.00',
                              helperText:
                                  'Debe ser mayor que el precio de costo.',
                              prefixIcon: Icon(Icons.payments_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final salePrice = double.tryParse(
                                value?.trim() ?? '',
                              );
                              final costPrice = double.tryParse(
                                _precioCostoController.text.trim(),
                              );
                              if (salePrice == null ||
                                  costPrice == null ||
                                  salePrice <= costPrice) {
                                return 'El precio de venta debe superar el costo.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder<ProductBloc, ProductState>(
                            builder: (context, state) {
                              final isLoading = state is ProductLoading;
                              return FilledButton.icon(
                                onPressed: isLoading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(
                                  isLoading
                                      ? 'Guardando...'
                                      : 'Guardar producto',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
