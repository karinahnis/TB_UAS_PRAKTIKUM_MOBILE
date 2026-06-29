import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/event.dart';
import '../models/pagination_meta.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService;

  List<EventSummary> _events = [];
  List<Category> _categories = [];
  EventDetail? _selectedEvent;
  PaginationMeta? _meta;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  String? _search;
  int? _categoryId;
  String? _city;
  String? _sort;

  EventProvider({required EventService eventService})
      : _eventService = eventService;

  List<EventSummary> get events => _events;
  List<Category> get categories => _categories;
  EventDetail? get selectedEvent => _selectedEvent;
  PaginationMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _meta?.hasMore ?? false;
  int? get categoryId => _categoryId;
  String? get sort => _sort;

  Future<void> loadCategories() async {
    try {
      _categories = await _eventService.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadEvents({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _events = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result =
          await _eventService.getEvents(page: _currentPage, search: _search, categoryId: _categoryId, city: _city, sort: _sort);
      _events.addAll(result.key);
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
    await loadEvents();
  }

  Future<void> loadEventDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEvent = await _eventService.getEventDetail(id);
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String? search) {
    _search = search;
  }

  void setCategoryFilter(int? categoryId) {
    _categoryId = categoryId;
  }

  void setCity(String? city) {
    _city = city;
  }

  void setSort(String? sort) {
    _sort = sort;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
