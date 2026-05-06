import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
  Future<void> addProduct(ProductModel product);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final FirebaseFirestore _firestore;

  MarketplaceRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ProductModel.fromJson(data);
    }).toList();
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).set(product.toJson());
  }
}
