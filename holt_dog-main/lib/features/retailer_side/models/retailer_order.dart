enum RetailerOrderStatus {
  delivered,
  processing,
  returned,
}

class RetailerOrder {
  final String orderId;
  final String customerName;
  final String orderDateLabel;
  final RetailerOrderStatus status;
  final int priceEgp;
  final bool highlightRow;

  const RetailerOrder({
    required this.orderId,
    required this.customerName,
    required this.orderDateLabel,
    required this.status,
    required this.priceEgp,
    this.highlightRow = false,
  });
}
