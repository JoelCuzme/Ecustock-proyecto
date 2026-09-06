import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecustock/data/models/product.dart';
import 'package:ecustock/data/repositories/product_repository.dart';

abstract class ProductEvent {}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  AddProduct(this.product);

  final Product product;
}

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  ProductsLoaded(this.products);

  final List<Product> products;
}

class ProductActionSuccess extends ProductState {
  ProductActionSuccess(this.message);

  final String message;
}

class ProductError extends ProductState {
  ProductError(this.message);

  final String message;
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({ProductRepository? repository})
      : _repository = repository ?? ProductRepository(),
        super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
  }

  final ProductRepository _repository;

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final products = await _repository.getProducts();
      emit(ProductsLoaded(products));
    } catch (error) {
      emit(ProductError(_formatError(error)));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      await _repository.addProduct(event.product);
      final updatedProducts = await _repository.getProducts();
      emit(ProductActionSuccess('Producto agregado correctamente.'));
      emit(ProductsLoaded(updatedProducts));
    } catch (error) {
      emit(ProductError(_formatError(error)));
    }
  }

  String _formatError(Object error) {
    final message = error.toString();
    if (message.contains('Exception:')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
