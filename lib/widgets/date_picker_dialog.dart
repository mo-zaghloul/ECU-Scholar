import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// Dialog for selecting a date from a date range using a calendar picker
/// 
/// Shows a Material dialog with a TableCalendar widget that allows users to
/// select a date within the specified range (typically a 14-day window).
/// 
/// Example:
/// ```dart
/// final selectedDate = await showDialog<DateTime>(
///   context: context,
///   builder: (context) => DatePickerDialog(
///     initialDate: DateTime.now(),
///     minDate: DateTime.now().subtract(Duration(days: 7)),
///     maxDate: DateTime.now().add(Duration(days: 7)),
///   ),
/// );
/// ```
class DatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;

  const DatePickerDialog({
    super.key,
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
  });

  @override
  State<DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
  }

  /// Check if a date is Friday (5 = Friday in DateTime.weekday)
  bool _isFriday(DateTime date) {
    return date.weekday == DateTime.friday;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final errorColor = Theme.of(context).colorScheme.error;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            // Calendar widget
            SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.48,
              child: TableCalendar(
              firstDay: widget.minDate,
              lastDay: widget.maxDate,
              focusedDay: _focusedDate,
              onDaySelected: (selectedDay, focusedDay) {
                // Close dialog immediately with selected date
                Navigator.pop(context, selectedDay);
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDate = focusedDay);
              },
              calendarFormat: CalendarFormat.month,
              pageAnimationEnabled: true,
              startingDayOfWeek: StartingDayOfWeek.saturday,
              selectedDayPredicate: (day) => isSameDay(widget.initialDate, day),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                // Styling for regular days
                defaultTextStyle: GoogleFonts.almarai(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                // Styling for Friday (off day) - grey
                weekendTextStyle: GoogleFonts.almarai(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                
                // Selected/current day styling (red circle - shows current page)
                selectedDecoration: BoxDecoration(
                  color: errorColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: GoogleFonts.almarai(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                // Today styling
                todayDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor,
                    width: 2,
                  ),
                ),
                todayTextStyle: GoogleFonts.almarai(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                // Cell padding - reduced to fit better
                cellPadding: const EdgeInsets.all(3.0),
              ),
              calendarBuilders: CalendarBuilders(
                // Custom builder to highlight Friday in grey
                defaultBuilder: (context, day, focusedDay) {
                  if (_isFriday(day)) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: GoogleFonts.almarai(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return null; // Use default styling
                },
                // Hide disabled days
                disabledBuilder: (context, day, focusedDay) {
                  return const SizedBox.shrink();
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.almarai(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: primaryColor,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: primaryColor,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.rectangle,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.almarai(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: errorColor,
                ),
                weekendStyle: GoogleFonts.almarai(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              locale: 'en_US',
              weekendDays: const [DateTime.friday], 
            ),
            ),
          ],
        ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: surfaceColor,
    );
  }
}
