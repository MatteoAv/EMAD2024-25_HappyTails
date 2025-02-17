import 'package:flutter/material.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// FutureProvider per gestire le date occupate
final busyDatesProvider = FutureProvider<List<DateTimeRange>>((ref) async {
  final bookings = await ref.watch(bookingsProvider.future);
  return bookings.map((book) {
    return DateTimeRange(
      start: DateTime.parse(book.dateBegin),
      end: DateTime.parse(book.dateEnd),
    );
  }).toList();
});

class BookingCalendar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busyDatesAsync = ref.watch(busyDatesProvider);
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disponibilità',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            busyDatesAsync.when(
              data: (busyDates) {
                return TableCalendar(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    weekdayStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.red),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black87),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black87),
                  ),
                  availableGestures: AvailableGestures.all,
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final isBusy = busyDates.any((d) =>
                        date.isAfter(d.start.subtract(Duration(days: 1))) &&
                        date.isBefore(d.end.add(Duration(days: 1)))
                      );

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isBusy ? Colors.redAccent.withOpacity(0.6) : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isBusy ? Colors.white : Colors.black87,
                              fontWeight: isBusy ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Errore: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
