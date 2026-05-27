import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../parent/create_event_screen.dart'; // We'll create this soon

class FamilyCalendarScreen extends StatefulWidget {
  final bool isParent;
  
  const FamilyCalendarScreen({super.key, required this.isParent});

  @override
  State<FamilyCalendarScreen> createState() => _FamilyCalendarScreenState();
}

class _FamilyCalendarScreenState extends State<FamilyCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyEventProvider>().loadEvents();
    });
  }

  List<FamilyEvent> _getEventsForDay(DateTime day) {
    final events = context.read<FamilyEventProvider>().events;
    return events.where((event) {
      return isSameDay(event.startTime, day) || 
             (day.isAfter(event.startTime) && day.isBefore(event.endTime)) ||
             isSameDay(event.endTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyEventProvider>();
    final selectedEvents = _getEventsForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch gia đình'),
        actions: [
          if (widget.isParent)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                );
              },
            ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<FamilyEvent>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: selectedEvents.isEmpty
                      ? const Center(child: Text('Không có sự kiện nào trong ngày này.'))
                      : ListView.builder(
                          itemCount: selectedEvents.length,
                          itemBuilder: (context, index) {
                            final event = selectedEvents[index];
                            final timeFormat = DateFormat('HH:mm');
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: ListTile(
                                leading: const Icon(Icons.event, color: Colors.blueAccent),
                                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (event.description.isNotEmpty) Text(event.description),
                                    Text('${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}'),
                                  ],
                                ),
                                trailing: widget.isParent 
                                  ? IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Xác nhận xóa'),
                                            content: const Text('Bạn có chắc muốn xóa sự kiện này?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await context.read<FamilyEventProvider>().deleteEvent(event.id);
                                        }
                                      },
                                    )
                                  : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
