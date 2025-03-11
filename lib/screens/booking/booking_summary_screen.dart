import 'package:flutter/material.dart';
import 'package:bookly/models/turf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingSummaryScreen extends StatelessWidget {
  final Turf turf;
  final DateTime date;
  final String timeSlot;
  final int duration; // in minutes
  final SportFacility selectedFacility;
  final bool isHalfBooking;

  const BookingSummaryScreen({
    Key? key,
    required this.turf,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.selectedFacility,
    this.isHalfBooking = false,
  }) : super(key: key);

  // Calculate total price based on selected facility, duration, and booking type
  double calculateTotalPrice() {
    final pricePerHour = isHalfBooking 
        ? selectedFacility.splitPricePerHour 
        : selectedFacility.pricePerHour;
    
    return pricePerHour * (duration / 60);
  }

  // Save booking to Firestore
  Future<void> _saveBooking(BuildContext context) async {
  // Create a scaffold messenger key to safely show snackbars
  final scaffoldMessengerKey = ScaffoldMessengerState();
  bool success = false;
  String errorMessage = '';
  
  // Show loading indicator
  final loadingDialog = showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    // Get current user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      errorMessage = 'You must be logged in to make a booking';
      return;
    }

    // Create booking data
    final bookingData = {
      'userId': currentUser.uid,
      'userName': currentUser.displayName ?? 'User',
      'userEmail': currentUser.email ?? '',
      'turfId': turf.id,
      'turfName': turf.name,
      'facilityId': selectedFacility.facilityId,
      'facilityName': selectedFacility.facilityName,
      'isHalfBooking': isHalfBooking,
      'sport': selectedFacility.supportedSports.isNotEmpty 
          ? selectedFacility.supportedSports[0] 
          : 'Not specified',
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'duration': duration,
      'totalPrice': calculateTotalPrice(),
      'status': 'confirmed', // Initial status
      'bookingTime': Timestamp.now(),
      'paymentStatus': 'pending', // Will be updated after payment
    };

    // Save to Firestore
    await FirebaseFirestore.instance.collection('bookings').add(bookingData);
    success = true;
  } catch (e) {
    errorMessage = 'Failed to create booking: ${e.toString()}';
  }

  // Close loading dialog safely
  Navigator.of(context, rootNavigator: true).pop();

  // Show appropriate message and navigate based on result
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking confirmed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Using a delayed call to navigate back to prevent context issues
    Future.delayed(Duration(milliseconds: 100), () {
      // Navigate to home or bookings page
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  } else if (errorMessage.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  // Show confirmation dialog
  void _showConfirmationDialog(BuildContext context) {
  final totalPrice = calculateTotalPrice();
  
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please confirm your booking details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildDialogRow('Venue', turf.name),
            _buildDialogRow('Facility', selectedFacility.facilityName),
            _buildDialogRow('Date', DateFormat('EEEE, MMMM d, yyyy').format(date)),
            _buildDialogRow('Time', timeSlot),
            _buildDialogRow('Duration', '$duration minutes'),
            SizedBox(height: 8),
            Divider(),
            _buildDialogRow(
              'Total Amount', 
              '₹${totalPrice.toStringAsFixed(2)}',
              isTotal: true,
            ),
            SizedBox(height: 8),
            Text(
              'Note: Payment will be collected at the venue.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Close dialog first, then save booking
              Navigator.of(dialogContext).pop();
              // Use the parent context (from original screen) to save booking
              _saveBooking(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice();
    final DateFormat dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Summary'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Divider(),
                    _buildDetailRow('Venue', turf.name),
                    _buildDetailRow('Facility', selectedFacility.facilityName),
                    _buildDetailRow('Booking Type', isHalfBooking ? 'Half Booking' : 'Full Booking'),
                    _buildDetailRow('Sport', selectedFacility.supportedSports.join(', ')),
                    _buildDetailRow('Date', dateFormatter.format(date)),
                    _buildDetailRow('Time', timeSlot),
                    _buildDetailRow('Duration', '$duration minutes'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Payment details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Divider(),
                    _buildDetailRow(
                      'Rate', 
                      '₹${isHalfBooking ? selectedFacility.splitPricePerHour : selectedFacility.pricePerHour} / hour'
                    ),
                    _buildDetailRow('Duration', '${duration / 60} hour(s)'),
                    Divider(),
                    _buildDetailRow(
                      'Total Amount', 
                      '₹${totalPrice.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Policy information
            Text(
              'Booking Policy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              '• Cancellations made 24 hours before the booking time will be eligible for a full refund.\n'
              '• Please arrive 15 minutes before your scheduled time.\n'
              '• Payment is required to confirm your booking.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            
            SizedBox(height: 24),
            
            // Proceed to payment button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Show confirmation dialog instead of proceeding to payment directly
                  _showConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build detail rows
  Widget _buildDialogRow(String label, String value, {bool isTotal = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            // Use a neutral gray that works in both themes
            color: Color(0xFF9E9E9E),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            // Use green for total but use white with shadow for dark mode compatibility
            color: isTotal ? Colors.green[700] : Color(0xFFEEEEEE),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            // Use a neutral gray that works in both themes
            color: Color(0xFF9E9E9E),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
            // Use green for total but use white with shadow for dark mode compatibility
            color: isTotal ? Colors.green[700] : Color(0xFFEEEEEE),
          ),
        ),
      ],
    ),
  );
}
}