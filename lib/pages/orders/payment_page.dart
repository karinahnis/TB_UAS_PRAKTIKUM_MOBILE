import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/order_provider.dart';
import '../../services/order_service.dart';

class PaymentPage extends StatefulWidget {
  final int orderId;

  const PaymentPage({super.key, required this.orderId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'bank_transfer';
  bool _isProcessing = false;

  final _methods = [
    {'value': 'bank_transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance},
    {'value': 'e_wallet', 'label': 'E-Wallet', 'icon': Icons.wallet},
    {'value': 'virtual_account', 'label': 'Virtual Account', 'icon': Icons.credit_card},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final order = provider.currentOrder;
          if (order == null) {
            return const Center(child: Text('Order tidak ditemukan'));
          }

          final priceFormat = NumberFormat('#,###');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ringkasan Pesanan',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Kode: ${order.orderCode}'),
                        const SizedBox(height: 4),
                        Text(
                            'Total: Rp ${priceFormat.format(order.totalAmount)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Pilih Metode Pembayaran',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: _selectedMethod,
                  onChanged: (value) =>
                      setState(() => _selectedMethod = value!),
                  child: Column(
                    children: _methods.map(
                      (method) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile<String>(
                          value: method['value'] as String,
                          title: Row(
                            children: [
                              Icon(method['icon'] as IconData, size: 24),
                              const SizedBox(width: 12),
                              Text(method['label'] as String),
                            ],
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Bayar Sekarang',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    final provider = context.read<OrderProvider>();
    final result = await provider.payOrder(widget.orderId, _selectedMethod);

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (result != null) {
      _showPaymentResult(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Pembayaran gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentResult(PayOrderResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.paymentStatus == 'success'
                  ? Icons.check_circle
                  : Icons.error,
              color: result.paymentStatus == 'success'
                  ? Colors.green
                  : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(result.paymentStatus == 'success'
                ? 'Pembayaran Berhasil'
                : 'Pembayaran Gagal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode Pembayaran: ${result.paymentCode}'),
            const SizedBox(height: 4),
            Text('Metode: ${result.paymentMethod}'),
            const SizedBox(height: 4),
            Text(
                'Total: Rp ${NumberFormat('#,###').format(result.amount)}'),
            if (result.generatedTicketCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${result.generatedTicketCount} tiket telah diterbitkan!',
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
