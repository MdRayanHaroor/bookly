import 'package:flutter/material.dart';
import 'package:bookly/models/booking.dart';
import 'package:bookly/services/booking_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookingsScreen extends StatefulWidget {
  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  
  Future<void> _loadBookings() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to view your bookings';
      });
      return;
    }

    try {
      final bookings = await _bookingService.getUserBookings();
      if (!mounted) return;
      
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load bookings: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _bookings.isEmpty
                  ? _buildEmptyView()
                  : _buildBookingsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBookings,
            child: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Book your first turf now',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to Home
            },
            child: Text('Browse Turfs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine if a booking is upcoming
bool isBookingUpcoming(Booking booking) {
  final now = DateTime.now();
  
  // Extract time from time slot (e.g., "02:00 PM - 04:00 PM" -> "02:00 PM")
  final timeSlotParts = booking.timeSlot.split(' - ');
  if (timeSlotParts.isEmpty) return false;
  
  final endTimeStr = timeSlotParts.length > 1 ? timeSlotParts[1] : timeSlotParts[0];
  
  // Parse the time
  DateTime endDateTime;
  try {
    // Create a datetime that combines the booking date with the end time of the slot
    final dateStr = "${booking.date.year}-${booking.date.month.toString().padLeft(2, '0')}-${booking.date.day.toString().padLeft(2, '0')}";
    final fullDateTimeStr = "$dateStr $endTimeStr";
    
    // Parse with intl package
    endDateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(fullDateTimeStr);
  } catch (e) {
    print('Error parsing time slot: $e');
    // Fallback to just using the date
    endDateTime = DateTime(
      booking.date.year, 
      booking.date.month, 
      booking.date.day, 
      23, 59  // End of day as fallback
    );
  }
  
  // A booking is upcoming if the end time is in the future
  return endDateTime.isAfter(now);
}

  Widget _buildBookingsList() {
  return RefreshIndicator(
    onRefresh: _loadBookings,
    child: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        
        // Use the improved method to check if booking is upcoming
        final isUpcoming = isBookingUpcoming(booking);
        
        // Get theme brightness to adapt colors
        final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
        
        // Choose colors based on theme
        final cardBorderColor = isUpcoming 
            ? Theme.of(context).primaryColor 
            : (isDarkTheme ? Colors.grey[700] : Colors.grey[300])!;
        
        final headerBgColor = isUpcoming 
            ? Theme.of(context).primaryColor 
            : (isDarkTheme ? Colors.grey[800] : Colors.grey[200]);
        
        final headerTextColor = isUpcoming 
            ? Colors.white 
            : (isDarkTheme ? Colors.white : Colors.grey[700]);
        
        final primaryTextColor = isDarkTheme ? Colors.white : Colors.black;
        final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
        final tertiaryTextColor = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

        // Debug print to verify dates and new logic
        print('Booking Date: ${booking.date} | Time Slot: ${booking.timeSlot} | IsUpcoming: $isUpcoming');

        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: cardBorderColor,
              width: isUpcoming ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: headerBgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUpcoming ? 'Upcoming' : 'Past',
                      style: TextStyle(
                        color: headerTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Booking ID: ${booking.id.substring(0, booking.id.length < 8 ? booking.id.length : 8)}',
                      style: TextStyle(
                        color: headerTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.turfName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.sports, size: 16, color: secondaryTextColor),
                        SizedBox(width: 4),
                        Text(
                          booking.sport ?? 'Sports',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.location_on, size: 16, color: secondaryTextColor),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.facilityName ?? 'Standard Court',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: secondaryTextColor),
                        SizedBox(width: 4),
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(booking.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: secondaryTextColor),
                        SizedBox(width: 4),
                        Text(
                          booking.timeSlot,
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            fontWeight: isUpcoming ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(${booking.duration} min)',
                          style: TextStyle(
                            fontSize: 12,
                            color: tertiaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(booking.status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                booking.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(booking.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (booking.paymentStatus != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.amber,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'PAYMENT: ${booking.paymentStatus!.toUpperCase()}',
                                    style: TextStyle(
                                      color: Colors.amber[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '₹${(booking.totalPrice ?? booking.amount).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (isUpcoming && (booking.status.toLowerCase() != 'cancelled'))
                      Column(
                        children: [
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.share),
                                  onPressed: () => _shareBooking(booking),
                                  label: Text('Share'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _showCancelDialog(booking),
                                  child: Text('Cancel'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _shareBooking(Booking booking) {
    // Format a nice message for sharing
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(booking.date);
    final sportType = booking.sport ?? 'sports';
    final facilityName = booking.facilityName ?? 'facility';
    
    final messageText = """
🏟️ Join me for ${sportType} at ${booking.turfName}! 🏟️

📅 Date: ${formattedDate}
⏰ Time: ${booking.timeSlot}
🎮 Sport: ${sportType}
🏆 Facility: ${facilityName}
⏱️ Duration: ${booking.duration} minutes

Let me know if you can make it! We'll have a great time! 🎉

Sent via Bookly App
""";

    // Share the formatted message
    Share.share(messageText, subject: 'Join me for ${sportType} at ${booking.turfName}!');
    
    // Track sharing analytics
    _trackSharingEvent(booking.id);
  }
  
  // Method to track when a booking is shared (could integrate with analytics)
  void _trackSharingEvent(String bookingId) {
    // Implement analytics tracking if needed
    print('Booking shared: $bookingId');
  }

  void _showCancelDialog(Booking booking) {
  // Using a separate BuildContext for the dialog
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Cancel Booking?'),
      content: Text('Are you sure you want to cancel this booking? Cancellation fees may apply based on our policy.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            // First, close the confirmation dialog
            Navigator.pop(dialogContext);
            
            // Store a reference to the current context
            final scaffoldContext = context;
            
            // Show loading indicator using a separate context
            showDialog(
              context: scaffoldContext,
              barrierDismissible: false,
              builder: (loadingContext) {
                return Center(child: CircularProgressIndicator());
              },
            );
            
            // Cancel the booking
            _bookingService.cancelBooking(booking.id).then((_) {
              // Close loading indicator if it's still showing
              if (Navigator.canPop(scaffoldContext)) {
                Navigator.pop(scaffoldContext);
              }
              
              // Show success message using a safe context
              if (mounted) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text('Booking cancelled successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Reload bookings
                _loadBookings();
              }
            }).catchError((e) {
              // Close loading indicator if it's still showing
              if (Navigator.canPop(scaffoldContext)) {
                Navigator.pop(scaffoldContext);
              }
              
              // Show error message using a safe context
              if (mounted) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text('Failed to cancel booking: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
          },
          child: Text('Yes, Cancel'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    ),
  );
}

  // Show share options dialog with preview
  void _showShareOptionsDialog(Booking booking, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                message,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.share),
            label: Text('Share Now'),
            onPressed: () {
              Navigator.pop(context);
              Share.share(message, subject: 'Join me for ${booking.sport ?? 'sports'} at ${booking.turfName}!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}