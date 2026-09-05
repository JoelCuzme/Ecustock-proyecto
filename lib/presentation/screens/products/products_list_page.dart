import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ecustock/data/models/product.dart';
import 'package:ecustock/presentation/bloc/product_bloc.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc()..add(LoadProducts()),
      child: const _ProductsListView(),
    );
  }
}

class _ProductsListView extends StatelessWidget {
  const _ProductsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError && state.message.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProductBloc>().add(LoadProducts()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = state is ProductsLoaded ? state.products : <Product>[];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 56),
                  const SizedBox(height: 16),
                  const Text('No hay productos registrados aún.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProductBloc>().add(LoadProducts()),
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    product.nombre.isNotEmpty ? product.nombre[0].toUpperCase() : 'P',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(product.nombre),
                subtitle: Text(product.codigoBarras.isNotEmpty ? product.codigoBarras : 'Sin código'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: product.stock > 0 ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${product.stock} disp.',
                    style: TextStyle(
                      color: product.stock > 0 ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/add'),
        tooltip: 'Agregar producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
