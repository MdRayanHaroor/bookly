import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;

  BookingCalendar({
    required this.onDateSelected,
    required this.selectedDate,
  });

  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  late PageController _pageController;
  late DateTime _currentMonth;
  late List<DateTime> _daysToShow;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _pageController = PageController(initialPage: 0);
    _generateDaysToShow();
  }

  void _generateDaysToShow() {
    // Generate 30 days from today
    final today = DateTime.now();
    _daysToShow = List.generate(30, (index) {
      return DateTime(today.year, today.month, today.day + index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar header
        Container(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text(
                'Select Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        // Scrollable days
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _daysToShow.length,
            itemBuilder: (context, index) {
              final day = _daysToShow[index];
              final isSelected = widget.selectedDate.year == day.year &&
                  widget.selectedDate.month == day.month &&
                  widget.selectedDate.day == day.day;
              
              // Check if day is today
              final isToday = day.year == DateTime.now().year &&
                  day.month == DateTime.now().month &&
                  day.day == DateTime.now().day;
              
              return GestureDetector(
                onTap: () {
                  widget.onDateSelected(day);
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : (isToday ? Colors.green[50] : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[300]!,
                      width: isToday && !isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(day),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        day.day.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('E').format(day),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}