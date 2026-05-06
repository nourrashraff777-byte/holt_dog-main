import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class MarketplaceSuccess extends MarketplaceState {
  final List<ProductModel> products;

  const MarketplaceSuccess(this.products);

  @override
  List<Object?> get props => [products];
}

class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError(this.message);

  @override
  List<Object?> get props => [message];
}

class MarketplaceProductAdding extends MarketplaceState {}

class MarketplaceProductAdded extends MarketplaceState {}
