import 'package:flutter/material.dart';

class TimeSlotSelector extends StatefulWidget {
  final Function(String) onTimeSelected;
  final String? selectedTime;

  TimeSlotSelector({
    required this.onTimeSelected,
    required this.selectedTime,
  });

  @override
  _TimeSlotSelectorState createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<TimeSlotSelector> {
  final List<String> _timeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          final time = _timeSlots[index];
          final isSelected = widget.selectedTime == time;
          
          return GestureDetector(
            onTap: () {
              widget.onTimeSelected(time);
            },
            child: Container(
              width: 100,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}