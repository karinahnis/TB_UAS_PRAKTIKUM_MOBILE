import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/event_provider.dart';
import '../../models/event.dart';
import 'event_detail_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<EventProvider>();
    provider.loadCategories();
    provider.loadEvents(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<EventProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildSortDropdown(),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari event...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<EventProvider>().setSearch(null);
                    context.read<EventProvider>().loadEvents(refresh: true);
                  },
                )
              : null,
        ),
        onSubmitted: (value) {
          context.read<EventProvider>().setSearch(value.trim());
          context.read<EventProvider>().loadEvents(refresh: true);
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        if (provider.categories.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _categoryChip('Semua', null, provider.categoryId),
              ...provider.categories.map(
                (cat) => _categoryChip(cat.name, cat.id, provider.categoryId),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryChip(String label, int? id, int? selectedId) {
    final isSelected = id == selectedId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          context.read<EventProvider>().setCategoryFilter(id);
          context.read<EventProvider>().loadEvents(refresh: true);
        },
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text('Urutkan: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: provider.sort,
                hint: const Text('Default'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Default')),
                  DropdownMenuItem(
                      value: 'event_at_asc', child: Text('Tanggal terdekat')),
                  DropdownMenuItem(
                      value: 'event_at_desc', child: Text('Tanggal terjauh')),
                  DropdownMenuItem(
                      value: 'price_asc', child: Text('Harga termurah')),
                  DropdownMenuItem(
                      value: 'price_desc', child: Text('Harga termahal')),
                ],
                onChanged: (value) {
                  provider.setSort(value);
                  provider.loadEvents(refresh: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventList() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadEvents(refresh: true),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }

        if (provider.events.isEmpty) {
          return const Center(child: Text('Tidak ada event'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadEvents(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.events.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.events.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _eventCard(provider.events[index]);
            },
          ),
        );
      },
    );
  }

  Widget _eventCard(EventSummary event) {
    final dateFormat = DateFormat('EEE, d MMM yyyy • HH:mm');
    final date = DateTime.parse(event.eventAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailPage(eventId: event.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.posterUrl != null)
              Image.network(
                event.posterUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: Colors.blue.shade50,
                  child: const Icon(Icons.event, size: 48, color: Colors.blue),
                ),
              )
            else
              Container(
                height: 120,
                color: Colors.blue.shade50,
                child: const Icon(Icons.event, size: 48, color: Colors.blue),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(event.category.name,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${event.venue.name}, ${event.venue.city}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(dateFormat.format(date),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  if (event.minPrice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Mulai dari Rp ${NumberFormat('#,###').format(event.minPrice!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
