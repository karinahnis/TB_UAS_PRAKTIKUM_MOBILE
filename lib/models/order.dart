class OrderItem {
  final int id;
  final int ticketTypeId;
  final String ticketTypeName;
  final String eventTitle;
  final int quantity;
  final double pricePerTicket;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.ticketTypeId,
    required this.ticketTypeName,
    required this.eventTitle,
    required this.quantity,
    required this.pricePerTicket,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      ticketTypeId: json['ticket_type_id'] as int,
      ticketTypeName: json['ticket_type_name'] as String,
      eventTitle: json['event_title'] as String,
      quantity: json['quantity'] as int,
      pricePerTicket: (json['price_per_ticket'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class Order {
  final int id;
  final String orderCode;
  final String status;
  final double totalAmount;
  final String expiredAt;
  final String? paidAt;
  final String? cancelledAt;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.totalAmount,
    required this.expiredAt,
    this.paidAt,
    this.cancelledAt,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderCode: json['order_code'] as String,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      expiredAt: json['expired_at'] as String,
      paidAt: json['paid_at'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      createdAt: json['created_at'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
