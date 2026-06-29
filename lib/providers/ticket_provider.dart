import 'package:flutter/foundation.dart';

import '../models/ticket.dart';
import '../services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService _ticketService;

  List<TicketListItem> _tickets = [];
  TicketDetail? _selectedTicket;
  bool _isLoading = false;
  String? _error;

  TicketProvider({required TicketService ticketService})
      : _ticketService = ticketService;

  List<TicketListItem> get tickets => _tickets;
  TicketDetail? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTickets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tickets = await _ticketService.getTickets();
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTicketDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTicket = await _ticketService.getTicketDetail(id);
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
