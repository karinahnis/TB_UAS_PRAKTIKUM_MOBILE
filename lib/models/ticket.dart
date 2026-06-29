class TicketEventSummary {
  final int id;
  final String title;
  final String venueName;
  final String city;
  final String eventAt;

  TicketEventSummary({
    required this.id,
    required this.title,
    required this.venueName,
    required this.city,
    required this.eventAt,
  });

  factory TicketEventSummary.fromJson(Map<String, dynamic> json) {
    return TicketEventSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      venueName: json['venue_name'] as String,
      city: json['city'] as String,
      eventAt: json['event_at'] as String,
    );
  }
}

class TicketListItem {
  final int id;
  final String ticketCode;
  final String status;
  final TicketEventSummary event;

  TicketListItem({
    required this.id,
    required this.ticketCode,
    required this.status,
    required this.event,
  });

  factory TicketListItem.fromJson(Map<String, dynamic> json) {
    return TicketListItem(
      id: json['id'] as int,
      ticketCode: json['ticket_code'] as String,
      status: json['status'] as String,
      event: TicketEventSummary.fromJson(json['event'] as Map<String, dynamic>),
    );
  }
}

class TicketHolder {
  final String name;
  final String email;

  TicketHolder({required this.name, required this.email});

  factory TicketHolder.fromJson(Map<String, dynamic> json) {
    return TicketHolder(
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class TicketEventDetail {
  final int id;
  final String title;
  final String venueName;
  final String venueAddress;
  final String city;
  final String eventAt;

  TicketEventDetail({
    required this.id,
    required this.title,
    required this.venueName,
    required this.venueAddress,
    required this.city,
    required this.eventAt,
  });

  factory TicketEventDetail.fromJson(Map<String, dynamic> json) {
    return TicketEventDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      venueName: json['venue_name'] as String,
      venueAddress: json['venue_address'] as String,
      city: json['city'] as String,
      eventAt: json['event_at'] as String,
    );
  }
}

class TicketTypeMini {
  final int id;
  final String name;
  final double price;

  TicketTypeMini({required this.id, required this.name, required this.price});

  factory TicketTypeMini.fromJson(Map<String, dynamic> json) {
    return TicketTypeMini(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class TicketDetail {
  final int id;
  final String ticketCode;
  final String qrCodeValue;
  final String status;
  final TicketHolder holder;
  final TicketEventDetail event;
  final TicketTypeMini ticketType;

  TicketDetail({
    required this.id,
    required this.ticketCode,
    required this.qrCodeValue,
    required this.status,
    required this.holder,
    required this.event,
    required this.ticketType,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    return TicketDetail(
      id: json['id'] as int,
      ticketCode: json['ticket_code'] as String,
      qrCodeValue: json['qr_code_value'] as String,
      status: json['status'] as String,
      holder: TicketHolder.fromJson(json['holder'] as Map<String, dynamic>),
      event:
          TicketEventDetail.fromJson(json['event'] as Map<String, dynamic>),
      ticketType:
          TicketTypeMini.fromJson(json['ticket_type'] as Map<String, dynamic>),
    );
  }
}
