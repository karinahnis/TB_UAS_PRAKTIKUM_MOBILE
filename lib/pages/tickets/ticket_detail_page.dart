import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../../providers/ticket_provider.dart';

class TicketDetailPage extends StatefulWidget {
  final int ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<TicketProvider>().loadTicketDetail(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: Consumer<TicketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        provider.loadTicketDetail(widget.ticketId),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final ticket = provider.selectedTicket;
          if (ticket == null) {
            return const Center(child: Text('Tiket tidak ditemukan'));
          }

          final dateFormat = DateFormat('EEE, d MMM yyyy • HH:mm');
          final eventDate = DateTime.parse(ticket.event.eventAt);

          Color statusColor;
          switch (ticket.status) {
            case 'active':
              statusColor = Colors.green;
              break;
            case 'used':
              statusColor = Colors.blue;
              break;
            case 'cancelled':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.grey;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: QrImageView(
                            data: ticket.qrCodeValue,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ticket.ticketCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ticket.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informasi Event',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const Divider(),
                        _infoRow(Icons.event, 'Event', ticket.event.title),
                        _infoRow(Icons.location_on, 'Tempat',
                            ticket.event.venueName),
                        _infoRow(Icons.map, 'Alamat',
                            ticket.event.venueAddress),
                        _infoRow(Icons.location_city, 'Kota',
                            ticket.event.city),
                        _infoRow(Icons.access_time, 'Waktu',
                            dateFormat.format(eventDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Tiket',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const Divider(),
                        _infoRow(Icons.confirmation_number,
                            'Tipe', ticket.ticketType.name),
                        _infoRow(
                          Icons.attach_money,
                          'Harga',
                          'Rp ${NumberFormat('#,###').format(ticket.ticketType.price)}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pemilik',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const Divider(),
                        _infoRow(
                            Icons.person, 'Nama', ticket.holder.name),
                        _infoRow(Icons.email, 'Email',
                            ticket.holder.email),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
