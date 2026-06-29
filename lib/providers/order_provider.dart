import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/pagination_meta.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;

  List<Order> _orders = [];
  Order? _currentOrder;
  PaginationMeta? _meta;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;

  OrderProvider({required OrderService orderService})
      : _orderService = orderService;

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  PaginationMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _meta?.hasMore ?? false;

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _orders = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.getOrders(page: _currentPage);
      _orders.addAll(result.key);
      _meta = result.value;
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !hasMore) return;
    _currentPage++;
    await loadOrders();
  }

  Future<bool> createOrder(int ticketTypeId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentOrder = await _orderService.createOrder(ticketTypeId, quantity);
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadOrderDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentOrder = await _orderService.getOrderDetail(id);
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(int id) async {
    try {
      _currentOrder = await _orderService.cancelOrder(id);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<PayOrderResult?> payOrder(int id, String paymentMethod) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.payOrder(id, paymentMethod);
      _isLoading = false;
      notifyListeners();
      return result;
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
