enum MarketplaceCategory {
  all,
  food,
  toys,
  accessories,
}

class MarketplaceProduct {
  final String id;
  final String title;
  final int priceEgp;
  final String imageUrl;
  final MarketplaceCategory category;

  const MarketplaceProduct({
    required this.id,
    required this.title,
    required this.priceEgp,
    required this.imageUrl,
    required this.category,
  });
}
