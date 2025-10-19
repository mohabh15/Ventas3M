import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/app_card.dart';
import '../../models/event.dart';
import 'add_event_modal.dart';
import 'edit_event_modal.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime selectedDate;
  late DateTime focusedMonth;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    focusedMonth = DateTime(selectedDate.year, selectedDate.month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 'guest';
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.loadEvents(userId);
  }

  Future<void> _showDeleteConfirmation(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: Text('¿Estás seguro de que quieres eliminar "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? 'guest';
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final success = await eventProvider.deleteEvent(event.id, userId);

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el evento')),
        );
      }
    }
  }

  String _getMonthName(int month) {
    return DateFormat.MMMM('es').format(DateTime(0, month));
  }

  bool _hasEventsOnDay(DateTime date, List<Event> events) {
    return events.any((event) =>
        event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events;
    final selectedDayEvents = events.where((event) =>
        event.date.year == selectedDate.year &&
        event.date.month == selectedDate.month &&
        event.date.day == selectedDate.day).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1);
                });
              },
            ),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: focusedMonth,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDatePickerMode: DatePickerMode.year,
                );
                if (picked != null) {
                  setState(() {
                    focusedMonth = DateTime(picked.year, picked.month);
                  });
                }
              },
              child: Text(
                '${_getMonthName(focusedMonth.month)} ${focusedMonth.year}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1);
                });
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddEventModal(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildCalendar(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedDayEvents.length,
              itemBuilder: (context, index) {
                final event = selectedDayEvents[index];
                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Text(event.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => EditEventModal(event: event),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteConfirmation(event),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events;

    final days = <Widget>[];
    for (int i = 1; i < firstWeekday; i++) {
      days.add(Container());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final isSelected = date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
      final hasEvents = _hasEventsOnDay(date, events);
      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : null,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                if (hasEvents)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      children: days,
    );
  }
}