import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../domain/entities/sharing_event.dart';

class GroupsMasterList extends StatefulWidget {
  final List<SharingEvent> events;
  final SharingEvent? selectedEvent;
  final ValueChanged<SharingEvent> onEventSelected;
  final VoidCallback onCreateEvent;

  const GroupsMasterList({
    super.key,
    required this.events,
    this.selectedEvent,
    required this.onEventSelected,
    required this.onCreateEvent,
  });

  @override
  State<GroupsMasterList> createState() => _GroupsMasterListState();
}

class _GroupsMasterListState extends State<GroupsMasterList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0 = Active, 1 = Settled

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'trip':
        return '✈️';
      case 'dinner':
        return '🍴';
      case 'home':
        return '🏠';
      case 'party':
        return '🎉';
      case 'groceries':
        return '🛒';
      case 'utilities':
        return '⚡';
      case 'entertainment':
        return '🎬';
      case 'transport':
        return '🚗';
      case 'shopping':
        return '🛍️';
      case 'sports':
        return '⚽';
      case 'work':
        return '💼';
      default:
        return '📁';
    }
  }

  List<SharingEvent> _getFilteredEvents() {
    final isSettledFilter = _selectedTab == 1;

    return widget.events.where((event) {
      final isSettled = event.status.toLowerCase() == 'settled';
      if (isSettled != isSettledFilter) return false;

      if (_searchQuery.isNotEmpty) {
        final nameMatch = event.name.toLowerCase().contains(_searchQuery);
        final descMatch =
            event.description.toLowerCase().contains(_searchQuery);
        if (!nameMatch && !descMatch) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final activeCount =
        widget.events.where((e) => e.status.toLowerCase() != 'settled').length;
    final settledCount =
        widget.events.where((e) => e.status.toLowerCase() == 'settled').length;

    final filtered = _getFilteredEvents();

    return Column(
      children: [
        // 1. Header with Title & Add button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Split & Groups',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.onCreateEvent,
                    icon: Icon(Icons.add_rounded,
                        color: colorScheme.primary, size: 18),
                    label: Text(
                      'New Event',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Search field
              TextField(
                controller: _searchController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search groups or events...',
                  hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor:
                      colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.customColors.glassStroke,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.customColors.glassStroke,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),

              // Segmented Active / Settled Tab
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      label: 'Active ($activeCount)',
                      tabIndex: 0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildTabButton(
                      label: 'Settled ($settledCount)',
                      tabIndex: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // 2. Scrollable Event Cards List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      _selectedTab == 0
                          ? 'No active events'
                          : 'No settled events',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final event = filtered[index];
                    return _buildEventTile(context, event);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabButton({required String label, required int tabIndex}) {
    final isSelected = _selectedTab == tabIndex;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabIndex;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, SharingEvent event) {
    final isSelected = widget.selectedEvent?.id == event.id;
    final colorScheme = context.colorScheme;
    final categoryEmoji = _getCategoryIcon(event.category);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 3.5,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          onTap: () => widget.onEventSelected(event),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              categoryEmoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          title: Text(
            event.name,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${event.participants.length} members • ${DateFormat.MMMd().format(event.startDate)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          trailing: CompactAmountText(
            amount: event.totalSpent,
            compact: true,
            style: context.customTypography.labelMediumMono.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
