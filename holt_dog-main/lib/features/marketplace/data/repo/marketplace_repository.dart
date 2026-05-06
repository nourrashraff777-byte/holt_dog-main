import '../data_sources/marketplace_remote_data_source.dart';
import '../models/product_model.dart';

abstract class MarketplaceRepository {
  Future<List<ProductModel>> getProducts();
  Future<void> saveProduct(ProductModel product);
}

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource _remoteDataSource;

  MarketplaceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductModel>> getProducts() async {
    return await _remoteDataSource.fetchProducts();
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    await _remoteDataSource.addProduct(product);
  }
}
