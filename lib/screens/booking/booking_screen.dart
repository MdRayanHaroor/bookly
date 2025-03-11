import 'package:flutter/material.dart';
import 'package:bookly/models/turf.dart';
import 'package:bookly/screens/booking/booking_summary_screen.dart';
import 'package:bookly/services/booking_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Turf turf;

  BookingScreen({required this.turf});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  String? _selectedTime;
  int _selectedDuration = 60; // Default duration is 60 minutes
  SportFacility? _selectedFacility;
  bool _isHalfBooking = false;
  
  // Track availability for each time
  Map<String, bool> _timeAvailability = {};
  bool _isCheckingAvailability = false;
  
  // Time options
  final List<String> _timeOptions = [
    '06:00 AM',
    '07:00 AM',
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
    '09:00 PM',
  ];
  
  // Duration options - 60 and 120 minutes
  final List<int> _durationOptions = [60, 120]; // in minutes

  // ScrollController for the horizontal time list
  final ScrollController _timeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    
    // Set default selected facility if available
    if (widget.turf.sportFacilities.isNotEmpty) {
      _selectedFacility = widget.turf.sportFacilities.first;
      
      // Check availability for all times for the default facility
      _checkAllTimesAvailability();
    }
  }

  @override
  void dispose() {
    _timeScrollController.dispose();
    super.dispose();
  }
  
  // Helper method to convert time to a time slot format
  String _getTimeSlotFromTime(String time) {
    // Parse the time
    final format = DateFormat('hh:mm a');
    final datetime = format.parse(time);
    
    // Calculate end time (1 hour later by default)
    final endDatetime = datetime.add(Duration(minutes: 60));
    
    // Format both times
    final startTimeStr = format.format(datetime);
    final endTimeStr = format.format(endDatetime);
    
    // Return in format "06:00 AM - 07:00 AM"
    return '$startTimeStr - $endTimeStr';
  }
  
  // Check all times availability with the current date and facility
  Future<void> _checkAllTimesAvailability() async {
    if (_selectedFacility == null) return;
    
    setState(() {
      _isCheckingAvailability = true;
    });
    
    // Reset availability map
    Map<String, bool> newAvailability = {};
    
    // Current time for validating past times
    final now = DateTime.now();
    final isToday = isSameDay(_selectedDay, now);
    
    // Get all booked time slots for this date and facility
    List<String> bookedTimeSlots = [];
    try {
      bookedTimeSlots = await _bookingService.getBookedTimeSlots(
        turfId: widget.turf.id,
        facilityId: _selectedFacility!.facilityId,
        date: _selectedDay,
        isHalfBooking: _isHalfBooking,
      );
    } catch (e) {
      print('Error fetching booked time slots: $e');
    }
    
    // Check each time
    for (String time in _timeOptions) {
      // Parse the time to check if it's in the past for today
      bool isPastTime = false;
      if (isToday) {
        final format = DateFormat('hh:mm a');
        final timeDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          format.parse(time).hour,
          format.parse(time).minute,
        );
        
        // Mark as unavailable if the time is in the past
        isPastTime = timeDateTime.isBefore(now);
      }
      
      // If the time is in the past, mark as unavailable
      if (isPastTime) {
        newAvailability[time] = false;
      } else {
        // Check if this time overlaps with any booked slot
        String timeSlot = _getTimeSlotFromTime(time);
        bool overlapsWithBooking = false;
        
        for (String bookedSlot in bookedTimeSlots) {
          // Parse booked time slot
          final format = DateFormat('hh:mm a');
          final bookedTimes = bookedSlot.split(' - ');
          if (bookedTimes.length != 2) continue;
          
          DateTime bookedStart = format.parse(bookedTimes[0]);
          DateTime bookedEnd = format.parse(bookedTimes[1]);
          DateTime currentStart = format.parse(time);
          DateTime currentEnd = currentStart.add(Duration(hours: 1));
          
          // Check for overlap (excluding touching times)
          bool hasOverlap = (
            (currentStart.isAtSameMomentAs(bookedStart)) ||
            (currentEnd.isAtSameMomentAs(bookedEnd)) ||
            (currentStart.isAfter(bookedStart) && currentStart.isBefore(bookedEnd)) ||
            (currentEnd.isAfter(bookedStart) && currentEnd.isBefore(bookedEnd)) ||
            (currentStart.isBefore(bookedStart) && currentEnd.isAfter(bookedEnd))
          );
          
          if (hasOverlap) {
            overlapsWithBooking = true;
            break;
          }
        }
        
        newAvailability[time] = !overlapsWithBooking;
      }
    }
    
    // Update state if still mounted
    if (mounted) {
      setState(() {
        _timeAvailability = newAvailability;
        _isCheckingAvailability = false;
        
        // If current selected time is not available, deselect it
        if (_selectedTime != null && !(_timeAvailability[_selectedTime] ?? true)) {
          _selectedTime = null;
        }
      });
    }
  }

  // Check if the booking overlaps with existing bookings
  Future<bool> _isEndTimeAvailable(String startTime, int durationMinutes) async {
    if (_selectedFacility == null) return false;
    
    // Parse the start time
    final format = DateFormat('hh:mm a');
    final startDateTime = format.parse(startTime);
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    
    // Get all existing bookings for this date and facility
    try {
      // This will request all booked slots from the backend for this facility and date
      List<String> bookedTimeSlots = await _bookingService.getBookedTimeSlots(
        turfId: widget.turf.id,
        facilityId: _selectedFacility!.facilityId,
        date: _selectedDay,
        isHalfBooking: _isHalfBooking,
      );
      
      // Check each booked slot for overlap
      for (String bookedSlot in bookedTimeSlots) {
        // Parse the booked slot times (format: "12:00 PM - 02:00 PM")
        List<String> times = bookedSlot.split(' - ');
        if (times.length != 2) continue; // Skip invalid format
        
        DateTime bookedStart = format.parse(times[0]);
        DateTime bookedEnd = format.parse(times[1]);
        
        // Check for overlap - if any of these conditions are true, there's an overlap
        bool hasOverlap = (
          // Case 1: New booking starts during an existing booking
          (startDateTime.isAfter(bookedStart) && startDateTime.isBefore(bookedEnd)) ||
          // Case 2: New booking ends during an existing booking
          (endDateTime.isAfter(bookedStart) && endDateTime.isBefore(bookedEnd)) ||
          // Case 3: New booking contains an existing booking
          (startDateTime.isBefore(bookedStart) && endDateTime.isAfter(bookedEnd)) ||
          // Case 4: New booking starts exactly at the same time as an existing booking
          (startDateTime.isAtSameMomentAs(bookedStart)) ||
          // Case 5: New booking ends exactly at the same time as an existing booking
          (endDateTime.isAtSameMomentAs(bookedEnd))
          // Removed conditions that treat "touching" bookings as overlapping:
          // Case 6: New booking starts at existing booking end time (they touch)
          // Case 7: New booking ends at existing booking start time (they touch)
        );
        
        if (hasOverlap) {
          return false; // Found an overlap
        }
      }
      
      return true; // No overlaps found
    } catch (e) {
      print('Error checking booking overlaps: $e');
      return false; // If there's an error, don't allow booking
    }
  }

  // Get the end time based on selected start time and duration
  String _getEndTime(String startTime, int durationMinutes) {
    final format = DateFormat('hh:mm a');
    final startDateTime = format.parse(startTime);
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    return format.format(endDateTime);
  }

  // Calendar section with fixed HeaderStyle reference
  Widget _buildCalendar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(Duration(days: 30)), // Allow booking 30 days in advance
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              // Reset selected time when day changes
              _selectedTime = null;
            });
            // Check availability for the new date
            _checkAllTimesAvailability();
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
          ),
        ),
      ),
    );
  }

  // Build horizontally scrollable time selection
  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_isCheckingAvailability)
              Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        
        // Display a note about availability
        Text(
          'Red times are already booked or in the past',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 12),
        
        // Horizontal scrollable time list
        Container(
          height: 50,
          child: ListView.builder(
            controller: _timeScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _timeOptions.length,
            itemBuilder: (context, index) {
              final time = _timeOptions[index];
              final isSelected = _selectedTime == time;
              final isAvailable = _timeAvailability[time] ?? true;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: isAvailable ? () {
                    setState(() {
                      _selectedTime = time;
                    });
                  } : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAvailable 
                          ? (isSelected ? Theme.of(context).primaryColor : Colors.grey[200])
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isAvailable 
                            ? (isSelected ? Colors.white : Colors.black87)
                            : Colors.red[300],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        decoration: !isAvailable ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.turf.name}'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Facility Section
            Text(
              'Select Facility',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            
            // Show facility selection cards
            if (widget.turf.sportFacilities.isEmpty)
              Center(
                child: Text(
                  'No facilities available for booking',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ...widget.turf.sportFacilities.map((facility) => _buildFacilityCard(facility)).toList(),
            
            SizedBox(height: 24),
            
            // Half booking option (only if selected facility supports it)
            if (_selectedFacility != null && _selectedFacility!.canBeSplit)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Type',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBookingTypeCard(
                          'Full Booking',
                          '₹${_selectedFacility!.pricePerHour.toStringAsFixed(0)}/hour',
                          !_isHalfBooking,
                          () {
                            setState(() => _isHalfBooking = false);
                            // Refresh availability when booking type changes
                            _checkAllTimesAvailability();
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildBookingTypeCard(
                          'Half Booking',
                          '₹${_selectedFacility!.splitPricePerHour.toStringAsFixed(0)}/hour',
                          _isHalfBooking,
                          () {
                            setState(() => _isHalfBooking = true);
                            // Refresh availability when booking type changes
                            _checkAllTimesAvailability();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            
            // Select Date Section
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            
            // Use the extracted calendar widget 
            _buildCalendar(),
            
            SizedBox(height: 24),
            
            // Time Selection Section with horizontal scroll
            _buildTimeSelection(),
            
            SizedBox(height: 24),
            
            // Select Duration Section
            Text(
              'Select Duration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _durationOptions.map((duration) {
                final isSelected = _selectedDuration == duration;
                return ChoiceChip(
                  label: Text('${duration} minutes'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDuration = selected ? duration : _selectedDuration;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            
            SizedBox(height: 32),
            
            // Summary Section
            if (_selectedFacility != null && _selectedTime != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow('Facility', _selectedFacility!.facilityName),
                          _buildSummaryRow('Sport', _selectedFacility!.supportedSports.join(', ')),
                          if (_selectedFacility!.canBeSplit)
                            _buildSummaryRow('Booking Type', _isHalfBooking ? 'Half Booking' : 'Full Booking'),
                          _buildSummaryRow('Date', DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)),
                          _buildSummaryRow(
                            'Time', 
                            '$_selectedTime - ${_getEndTime(_selectedTime!, _selectedDuration)}'
                          ),
                          _buildSummaryRow('Duration', '$_selectedDuration minutes'),
                          Divider(),
                          _buildSummaryRow(
                            'Total Price', 
                            '₹${_calculatePrice().toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
            SizedBox(height: 24),
            
            // Proceed to Booking Button with fixed text color for disabled state
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed() && !_isCheckingAvailability
                    ? () => _proceedToBooking()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[700], // Fixed text color for disabled state
                ),
                child: Text(
                  'Proceed to Booking',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  // Build a facility selection card
  Widget _buildFacilityCard(SportFacility facility) {
    final isSelected = _selectedFacility?.facilityId == facility.facilityId;
    
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFacility = facility;
            // Reset half booking when changing facility
            _isHalfBooking = false;
            // Reset selected time
            _selectedTime = null;
          });
          
          // Check availability for the new facility
          _checkAllTimesAvailability();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Facility Image or Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: facility.imageUrl != null && facility.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          facility.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _getFacilityIcon(facility.facilityType);
                          },
                        ),
                      )
                    : _getFacilityIcon(facility.facilityType),
              ),
              SizedBox(width: 16),
              
              // Facility Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            facility.facilityName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    
                    // Facility Type
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        facility.facilityType,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Sports
                    Text(
                      'Sports: ${facility.supportedSports.join(", ")}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    
                    // Price
                    Row(
                      children: [
                        Text(
                          '₹${facility.pricePerHour.toStringAsFixed(0)} / hour',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        if (facility.canBeSplit) ...[
                          SizedBox(width: 8),
                          Text(
                            '(Half: ₹${facility.splitPricePerHour.toStringAsFixed(0)})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Available units
                    if (facility.availableUnits > 1)
                      Text(
                        '${facility.availableUnits} units available',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build booking type card (Full/Half)
  Widget _buildBookingTypeCard(String title, String price, bool isSelected, VoidCallback onTap) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8),
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Get icon based on facility type
  Widget _getFacilityIcon(String facilityType) {
    IconData iconData;
    Color iconColor;
    
    switch (facilityType.toLowerCase()) {
      case 'turf':
        iconData = Icons.sports_soccer;
        iconColor = Colors.green;
        break;
      case 'court':
      case 'synthetic court':
        iconData = Icons.sports_tennis;
        iconColor = Colors.orange;
        break;
      case 'table':
        iconData = Icons.table_bar;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.sports;
        iconColor = Colors.purple;
    }
    
    return Center(
      child: Icon(
        iconData,
        size: 40,
        color: iconColor,
      ),
    );
  }
  
  // Helper method to build summary rows with better dark theme support
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              // Use theme's text color with opacity to work in both light and dark modes
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              // Use theme's text color for normal text, green for total in both themes
              color: isTotal ? Colors.green[700] : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
  
  // Calculate price based on duration and booking type
  double _calculatePrice() {
    if (_selectedFacility == null) return 0;
    
    final pricePerHour = _isHalfBooking 
        ? _selectedFacility!.splitPricePerHour 
        : _selectedFacility!.pricePerHour;
    
    return pricePerHour * (_selectedDuration / 60);
  }
  
  // Check if all required fields are filled and time slot is available
  bool _canProceed() {
    return _selectedFacility != null && 
           _selectedTime != null &&
           _selectedDuration > 0 &&
           (_timeAvailability[_selectedTime] ?? false); // Check if the start time is available
  }
  
  // Navigate to booking summary screen
  void _proceedToBooking() async {
    if (_selectedFacility == null || _selectedTime == null) return;
    
    // Get the formatted time slot for the booking
    final endTime = _getEndTime(_selectedTime!, _selectedDuration);
    final timeSlot = '$_selectedTime - $endTime';
    
    // Double-check if the entire duration is available and no overlapping bookings exist
    bool isDurationAvailable = await _isEndTimeAvailable(_selectedTime!, _selectedDuration);
    
    if (!isDurationAvailable) {
      // Show error message with more specific information
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This time slot overlaps with an existing booking. Please choose a different time.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Refresh availability
      _checkAllTimesAvailability();
      return;
    }
    
    // If available, proceed to booking
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSummaryScreen(
          turf: widget.turf,
          date: _selectedDay,
          timeSlot: timeSlot,
          duration: _selectedDuration,
          selectedFacility: _selectedFacility!,
          isHalfBooking: _isHalfBooking,
        ),
      ),
    ).then((_) {
      // When returning from the summary screen, refresh availability
      // in case a booking was made
      _checkAllTimesAvailability();
    });
  }
}