import 'package:flutter/material.dart';
import 'package:bookly/models/turf.dart';
import 'package:bookly/screens/profile/my_bookings_screen.dart';
import 'package:bookly/services/booking_service.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final Turf turf;
  final DateTime date;
  final String timeSlot;
  final int duration;
  final int sideSize;
  final int courtNumber;
  final double amount;

  PaymentScreen({
    required this.turf,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.sideSize,
    required this.courtNumber,
    required this.amount,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _bookingService = BookingService();
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'upi';

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Show booking confirmation dialog
      await _showConfirmationDialog();
      
      // Process the booking in Firebase
      await _bookingService.createBooking(
        turfId: widget.turf.id,
        turfName: widget.turf.name,
        date: widget.date,
        timeSlot: widget.timeSlot,
        duration: widget.duration,
        courtNumber: widget.courtNumber,
        sideSize: widget.sideSize,
        amount: widget.amount,
        paymentMethod: _selectedPaymentMethod,
      );

      // Show success message and navigate to My Bookings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking confirmed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to My Bookings screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyBookingsScreen()),
        (route) => route.isFirst, // Keep only the home route
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Turf: ${widget.turf.name}'),
                SizedBox(height: 8),
                Text('Date: ${DateFormat('EEE, MMM d').format(widget.date)}'),
                SizedBox(height: 4),
                Text('Time: ${widget.timeSlot}'),
                SizedBox(height: 4),
                Text('Court: ${widget.sideSize}-a-side Court ${widget.courtNumber}'),
                SizedBox(height: 4),
                Text('Amount: ₹${widget.amount.toStringAsFixed(0)}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isProcessing = false;
                });
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                // Continue with payment processing
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Turf',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  widget.turf.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat('EEE, MMM d').format(widget.date),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  widget.timeSlot,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Court',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${widget.sideSize}-a-side Court ${widget.courtNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount to Pay',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '₹${widget.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.account_balance_wallet),
                          SizedBox(width: 12),
                          Text('UPI Payment'),
                        ],
                      ),
                      value: 'upi',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.credit_card),
                          SizedBox(width: 12),
                          Text('Credit/Debit Card'),
                        ],
                      ),
                      value: 'card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.account_balance),
                          SizedBox(width: 12),
                          Text('Net Banking'),
                        ],
                      ),
                      value: 'netbanking',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            child: _isProcessing
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Pay ₹${widget.amount.toStringAsFixed(0)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
      ),
    );
  }
}