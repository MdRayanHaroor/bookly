import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookly/models/booking.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = Uuid();

  // Create a new booking with sport facilities
  Future<String> createBooking({
    required String turfId,
    required String turfName,
    required String facilityId,
    required String facilityName,
    required bool isHalfBooking,
    required String sport,
    required DateTime date,
    required String timeSlot,
    required int duration,
    required double totalPrice,
    String paymentMethod = 'pending', // Not required
    // Optional parameters for backward compatibility
    int? courtNumber,
    int? sideSize,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final bookingId = _uuid.v4();
    final paymentId = _uuid.v4();

    // Create booking document with all the new fields
    Map<String, dynamic> bookingData = {
      '_id': bookingId,
      'userId': user.uid,
      'userName': user.displayName ?? 'User',
      'userEmail': user.email ?? '',
      'turfId': turfId,
      'turfName': turfName,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'isHalfBooking': isHalfBooking,
      'sport': sport,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'duration': duration,
      'totalPrice': totalPrice,
      'amount': totalPrice, // For backward compatibility
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'status': 'confirmed',
      'paymentStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'bookingTime': Timestamp.now(),
    };

    // Add optional fields if provided
    if (courtNumber != null) {
      bookingData['courtNumber'] = courtNumber;
    }
    if (sideSize != null) {
      bookingData['sideSize'] = sideSize;
    }

    // Save to Firestore
    await _firestore.collection('bookings').doc(bookingId).set(bookingData);
    
    return bookingId;
  }

  // Get user bookings
  Future<List<Booking>> getUserBookings() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    print('Fetching bookings for user ID: ${user.uid}');

    // Get bookings from Firestore
    final snapshot = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .get();

    print('Found ${snapshot.docs.length} bookings');

    // Convert to Booking objects - handle both fromMap and fromJson
    return snapshot.docs.map((doc) {
      print('Processing booking document: ${doc.id}');
      final data = doc.data();
      
      // Add document ID as _id if not present
      if (!data.containsKey('_id')) {
        data['_id'] = doc.id;
      }
      
      try {
        // Try to use new model first
        return Booking.fromMap(data, doc.id);
      } catch (e) {
        print('Error parsing with fromMap, trying fromJson: $e');
        try {
          // Fall back to old model if needed
          return Booking.fromJson(data);
        } catch (e2) {
          print('Error parsing booking: $e2');
          throw Exception('Failed to parse booking data');
        }
      }
    }).toList();
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  // Check if a time slot is available - for facilities-based bookings
  Future<bool> isFacilityAvailable({
    required String turfId,
    required String facilityId,
    required DateTime date,
    required String timeSlot,
    bool isHalfBooking = false, // Not required
  }) async {
    try {
      print("Checking availability for: Turf $turfId, Facility $facilityId, Date ${date.toIso8601String()}, Time $timeSlot, HalfBooking: $isHalfBooking");
      
      // Start of the selected date (midnight)
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      // Query bookings for the same date
      final snapshot = await _firestore
          .collection('bookings')
          .where('turfId', isEqualTo: turfId)
          .where('facilityId', isEqualTo: facilityId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      
      // Check if there are any conflicting bookings
      final conflictingBookings = snapshot.docs.where((doc) {
        final data = doc.data();
        
        // Skip cancelled bookings
        if (data['status'] == 'cancelled') {
          return false;
        }
        
        // Check if it's the same time slot
        if (data['timeSlot'] != timeSlot) {
          return false;
        }
        
        // For half bookings, we can have two bookings for the same facility
        // if both are half bookings. Otherwise, the facility is considered booked.
        final existingIsHalfBooking = data['isHalfBooking'] == true;
        
        // If either booking is full, there's a conflict
        if (!existingIsHalfBooking || !isHalfBooking) {
          return true;
        }
        
        // If both are half bookings, check how many half bookings already exist
        return _countHalfBookings(snapshot.docs, timeSlot) >= 2;
      }).toList();
      
      final bool available = conflictingBookings.isEmpty;
      print("Is facility available: $available (found ${conflictingBookings.length} conflicting bookings)");
      return available;
    } catch (e) {
      print('Error checking facility availability: $e');
      return false;
    }
  }
  
  // Get all booked time slots for a facility on a specific date
  Future<List<String>> getBookedTimeSlots({
    required String turfId,
    required String facilityId,
    required DateTime date,
    bool isHalfBooking = false, // Not required
  }) async {
    try {
      print("Getting booked slots for: Turf $turfId, Facility $facilityId, Date ${date.toIso8601String()}, HalfBooking: $isHalfBooking");
      
      // Start of the selected date (midnight)
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      // Query bookings for the same date
      final snapshot = await _firestore
          .collection('bookings')
          .where('turfId', isEqualTo: turfId)
          .where('facilityId', isEqualTo: facilityId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      
      // Filter out cancelled bookings and collect time slots
      List<String> bookedSlots = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Skip cancelled bookings
        if (data['status'] == 'cancelled') {
          continue;
        }
        
        // If it's a half booking and we're looking for full bookings, or vice versa,
        // we still need to consider them to prevent double booking
        final existingIsHalfBooking = data['isHalfBooking'] == true;
        
        // For simplicity, treat all bookings as conflicting in this implementation
        // A more sophisticated approach could handle half bookings differently
        
        // Add the time slot to our list
        if (data.containsKey('timeSlot') && data['timeSlot'] is String) {
          bookedSlots.add(data['timeSlot']);
        }
      }
      
      print("Found ${bookedSlots.length} booked time slots");
      return bookedSlots;
    } catch (e) {
      print('Error getting booked time slots: $e');
      return [];
    }
  }
  
  // Helper method to count half bookings for a time slot
  int _countHalfBookings(List<QueryDocumentSnapshot> docs, String timeSlot) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['isHalfBooking'] == true && 
             data['timeSlot'] == timeSlot && 
             data['status'] != 'cancelled';
    }).length;
  }

  // Legacy availability check for backward compatibility
  Future<bool> isTimeSlotAvailable({
    required String turfId,
    required DateTime date,
    required String timeSlot,
    required int courtNumber,
    required int sideSize,
  }) async {
    try {
      // Format date to only include year-month-day (strip time)
      final String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      print("Checking availability for: Turf $turfId, Date $formattedDate, Time $timeSlot, Court $courtNumber, Format $sideSize");
      
      // Query on matches for any booking with the same date (regardless of time)
      final snapshot = await _firestore
          .collection('bookings')
          .where('turfId', isEqualTo: turfId)
          .get();
          
      // Filter the results manually to check all conditions
      final matchingBookings = snapshot.docs.where((doc) {
        final bookingData = doc.data();
        
        // Check for standard date format
        if (bookingData.containsKey('date') && bookingData['date'] is String) {
          final bookingDate = bookingData['date'] as String;
          return bookingDate.contains(formattedDate) && 
                 bookingData['timeSlot'] == timeSlot &&
                 bookingData['courtNumber'] == courtNumber &&
                 bookingData['sideSize'] == sideSize &&
                 bookingData['status'] != 'cancelled';
        } 
        // Check for Timestamp date format
        else if (bookingData.containsKey('date') && bookingData['date'] is Timestamp) {
          final timestamp = bookingData['date'] as Timestamp;
          final bookingDate = timestamp.toDate();
          final bookingFormattedDate = "${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}";
          
          return bookingFormattedDate == formattedDate && 
                 bookingData['timeSlot'] == timeSlot &&
                 bookingData['courtNumber'] == courtNumber &&
                 bookingData['sideSize'] == sideSize &&
                 bookingData['status'] != 'cancelled';
        }
        
        return false;
      }).toList();
      
      final bool available = matchingBookings.isEmpty;
      print("Is available: $available (found ${matchingBookings.length} bookings)");
      return available;
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }
}