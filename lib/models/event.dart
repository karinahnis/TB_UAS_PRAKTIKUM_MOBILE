class CategoryRef {
  final int id;
  final String name;

  CategoryRef({required this.id, required this.name});

  factory CategoryRef.fromJson(Map<String, dynamic> json) {
    return CategoryRef(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class VenueRef {
  final int id;
  final String name;
  final String city;

  VenueRef({required this.id, required this.name, required this.city});

  factory VenueRef.fromJson(Map<String, dynamic> json) {
    return VenueRef(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
    );
  }
}

class EventSummary {
  final int id;
  final String title;
  final String slug;
  final String? posterUrl;
  final CategoryRef category;
  final VenueRef venue;
  final String eventAt;
  final double? minPrice;
  final bool isAvailable;

  EventSummary({
    required this.id,
    required this.title,
    required this.slug,
    this.posterUrl,
    required this.category,
    required this.venue,
    required this.eventAt,
    this.minPrice,
    required this.isAvailable,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      posterUrl: json['poster_url'] as String?,
      category: CategoryRef.fromJson(json['category'] as Map<String, dynamic>),
      venue: VenueRef.fromJson(json['venue'] as Map<String, dynamic>),
      eventAt: json['event_at'] as String,
      minPrice: (json['min_price'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool,
    );
  }
}

class VenueDetail {
  final int id;
  final String name;
  final String address;
  final String city;

  VenueDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
  });

  factory VenueDetail.fromJson(Map<String, dynamic> json) {
    return VenueDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
    );
  }
}

class TicketType {
  final int id;
  final String name;
  final double price;
  final int quota;
  final int soldQuantity;
  final int remainingQuantity;

  TicketType({
    required this.id,
    required this.name,
    required this.price,
    required this.quota,
    required this.soldQuantity,
    required this.remainingQuantity,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quota: json['quota'] as int,
      soldQuantity: json['sold_quantity'] as int,
      remainingQuantity: json['remaining_quantity'] as int,
    );
  }
}

class EventDetail {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String? posterUrl;
  final CategoryRef category;
  final VenueDetail venue;
  final String eventAt;
  final String salesStartAt;
  final String salesEndAt;
  final String status;
  final List<TicketType> ticketTypes;

  EventDetail({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.posterUrl,
    required this.category,
    required this.venue,
    required this.eventAt,
    required this.salesStartAt,
    required this.salesEndAt,
    required this.status,
    required this.ticketTypes,
  });

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    return EventDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      posterUrl: json['poster_url'] as String?,
      category: CategoryRef.fromJson(json['category'] as Map<String, dynamic>),
      venue: VenueDetail.fromJson(json['venue'] as Map<String, dynamic>),
      eventAt: json['event_at'] as String,
      salesStartAt: json['sales_start_at'] as String,
      salesEndAt: json['sales_end_at'] as String,
      status: json['status'] as String,
      ticketTypes: (json['ticket_types'] as List<dynamic>)
          .map((e) => TicketType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
