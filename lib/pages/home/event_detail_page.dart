import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/event_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/event.dart';
import '../orders/order_page.dart';

class EventDetailPage extends StatefulWidget {
  final int eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<EventProvider>().loadEventDetail(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Event')),
      body: Consumer<EventProvider>(
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
                        provider.loadEventDetail(widget.eventId),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final event = provider.selectedEvent;
          if (event == null) {
            return const Center(child: Text('Event tidak ditemukan'));
          }

          return _buildContent(event);
        },
      ),
    );
  }

  Widget _buildContent(EventDetail event) {
    final dateFormat = DateFormat('EEE, d MMM yyyy • HH:mm');
    final eventDate = DateTime.parse(event.eventAt);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.posterUrl != null)
            Image.network(
              event.posterUrl!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: Colors.blue.shade50,
                child: const Icon(Icons.event, size: 64, color: Colors.blue),
              ),
            )
          else
            Container(
              height: 180,
              color: Colors.blue.shade50,
              child: const Icon(Icons.event, size: 64, color: Colors.blue),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(event.category.name,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${event.venue.name}\n${event.venue.address}, ${event.venue.city}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(dateFormat.format(eventDate),
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(event.description),
                const SizedBox(height: 24),
                const Text(
                  'Tiket Tersedia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...event.ticketTypes.map(
                  (tt) => _ticketTypeCard(event, tt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketTypeCard(EventDetail event, TicketType tt) {
    final priceFormat = NumberFormat('#,###');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tt.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${priceFormat.format(tt.price)}',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sisa ${tt.remainingQuantity} dari ${tt.quota}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: tt.remainingQuantity > 0
                  ? () => _buyTicket(event, tt)
                  : null,
              child: Text(tt.remainingQuantity > 0 ? 'Beli' : 'Habis'),
            ),
          ],
        ),
      ),
    );
  }

  void _buyTicket(EventDetail event, TicketType tt) {
    final quantityController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Beli Tiket ${tt.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Event: ${event.title}'),
            const SizedBox(height: 8),
            Text('Harga: Rp ${NumberFormat('#,###').format(tt.price)}'),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(quantityController.text);
              if (qty == null || qty < 1 || qty > 10) return;
              Navigator.of(ctx).pop();

              final orderProvider = context.read<OrderProvider>();
              orderProvider.createOrder(tt.id, qty).then((success) {
                if (success && mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OrderPage(),
                    ),
                  );
                }
              });
            },
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }
}
