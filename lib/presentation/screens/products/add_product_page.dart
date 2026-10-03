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
  static const _maxMariaDbInt = 2147483647;
  static const _maxMariaDbDecimal = 99999999.99;

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
      stock: int.parse(_stockController.text.trim()),
      stockMinimo: int.parse(_stockMinimoController.text.trim()),
      precioCosto: double.parse(_precioCostoController.text.trim()),
      precioVenta: double.parse(_precioVentaController.text.trim()),
    );

    context.read<ProductBloc>().add(AddProduct(product));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.pop();
        }

        if (state is ProductError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nuevo producto')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
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
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final stock = int.tryParse(value?.trim() ?? '');
                      if (stock == null ||
                          stock < 0 ||
                          stock > _maxMariaDbInt) {
                        return 'Ingresa un entero entre 0 y $_maxMariaDbInt.';
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
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final stockMinimo = int.tryParse(value?.trim() ?? '');
                      if (stockMinimo == null ||
                          stockMinimo < 0 ||
                          stockMinimo > _maxMariaDbInt) {
                        return 'Ingresa un entero entre 0 y $_maxMariaDbInt.';
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
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final price = double.tryParse(value?.trim() ?? '');
                      if (price == null ||
                          !price.isFinite ||
                          price <= 0 ||
                          price > _maxMariaDbDecimal) {
                        return 'El precio de costo debe ser mayor que cero y no superar $_maxMariaDbDecimal.';
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
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final salePrice = double.tryParse(value?.trim() ?? '');
                      final costPrice = double.tryParse(
                        _precioCostoController.text.trim(),
                      );
                      if (salePrice == null ||
                          !salePrice.isFinite ||
                          costPrice == null ||
                          !costPrice.isFinite ||
                          salePrice <= costPrice ||
                          salePrice > _maxMariaDbDecimal) {
                        return 'El precio de venta debe superar el costo y no superar $_maxMariaDbDecimal.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      final isLoading = state is ProductLoading;
                      return ElevatedButton.icon(
                        onPressed: isLoading ? null : _submit,
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
                          isLoading ? 'Guardando...' : 'Guardar producto',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
