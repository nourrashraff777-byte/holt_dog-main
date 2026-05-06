import 'marketplace_category.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final MarketplaceCategory category;
  final String retailerId;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.retailerId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] is String
          ? int.tryParse(json['price'] as String) ?? 0
          : (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      category: MarketplaceCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String?),
        orElse: () => MarketplaceCategory.all,
      ),
      retailerId: json['retailerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category.name,
      'retailerId': retailerId,
    };
  }
}
