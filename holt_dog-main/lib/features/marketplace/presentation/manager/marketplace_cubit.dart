import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/marketplace_repository.dart';
import '../../data/models/product_model.dart';
import 'marketplace_state.dart';

class MarketplaceCubit extends Cubit<MarketplaceState> {
  final MarketplaceRepository _repository;

  MarketplaceCubit(this._repository) : super(MarketplaceInitial());

  Future<void> fetchProducts() async {
    emit(MarketplaceLoading());
    try {
      final products = await _repository.getProducts();
      emit(MarketplaceSuccess(products));
    } catch (e) {
      emit(MarketplaceError(e.toString()));
    }
  }

  Future<void> addProduct(ProductModel product) async {
    emit(MarketplaceProductAdding());
    try {
      await _repository.saveProduct(product);
      emit(MarketplaceProductAdded());
      await fetchProducts(); // Refresh the list
    } catch (e) {
      emit(MarketplaceError(e.toString()));
    }
  }
}
