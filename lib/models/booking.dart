import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String turfId;
  final String turfName;
  final DateTime date;
  final String timeSlot;
  final int duration;
  final double amount;
  final String status;
  final DateTime? createdAt;
  final DateTime? cancelledAt;
  
  // Optional fields for court-based bookings
  final int? courtNumber;
  final int? sideSize;
  
  // Optional fields for facility-based bookings
  final String? facilityId;
  final String? facilityName;
  final bool isHalfBooking;
  final String? sport;
  final double? totalPrice;
  final String? paymentStatus;
  final DateTime? bookingTime;
  final String? paymentId;
  final String? paymentMethod;

  Booking({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.turfId,
    required this.turfName,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.amount,
    required this.status,
    this.createdAt,
    this.cancelledAt,
    this.courtNumber,
    this.sideSize = 5,
    this.facilityId,
    this.facilityName,
    this.isHalfBooking = false,
    this.sport,
    this.totalPrice,
    this.paymentStatus,
    this.bookingTime,
    this.paymentId,
    this.paymentMethod,
  });

  // Legacy parsing method for backward compatibility
  factory Booking.fromJson(Map<String, dynamic> json) {
    // Handle different date formats
    DateTime parseDate(dynamic dateData) {
      if (dateData is Timestamp) {
        return dateData.toDate();
      } else if (dateData is String) {
        return DateTime.parse(dateData);
      }
      return DateTime.now(); // Default fallback
    }

    return Booking(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      turfId: json['turfId'] ?? '',
      turfName: json['turfName'] ?? '',
      date: json['date'] != null ? parseDate(json['date']) : DateTime.now(),
      timeSlot: json['timeSlot'] ?? '',
      duration: json['duration'] ?? 60,
      courtNumber: json['courtNumber'],
      sideSize: json['sideSize'] ?? 5,
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? 
                 (json['createdAt'] is Timestamp ? 
                  (json['createdAt'] as Timestamp).toDate() : 
                  DateTime.parse(json['createdAt'])) : 
                 null,
      cancelledAt: json['cancelledAt'] != null ? 
                  (json['cancelledAt'] is Timestamp ? 
                   (json['cancelledAt'] as Timestamp).toDate() : 
                   DateTime.parse(json['cancelledAt'])) : 
                  null,
      // Add support for newer fields if they exist
      facilityId: json['facilityId'],
      facilityName: json['facilityName'],
      isHalfBooking: json['isHalfBooking'] ?? false,
      sport: json['sport'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      totalPrice: json['totalPrice'] != null ? (json['totalPrice']).toDouble() : null,
      paymentStatus: json['paymentStatus'],
      bookingTime: json['bookingTime'] != null ? 
                  (json['bookingTime'] is Timestamp ? 
                   (json['bookingTime'] as Timestamp).toDate() : 
                   DateTime.parse(json['bookingTime'])) : 
                  null,
      paymentId: json['paymentId'],
      paymentMethod: json['paymentMethod'],
    );
  }

  // New parsing method for the updated schema
  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    // Handle different date formats
    DateTime parseDate(dynamic dateData) {
      if (dateData is Timestamp) {
        return dateData.toDate();
      } else if (dateData is String) {
        return DateTime.parse(dateData);
      }
      return DateTime.now(); // Default fallback
    }

    return Booking(
      id: map['_id'] ?? id,
      userId: map['userId'] ?? '',
      userName: map['userName'],
      userEmail: map['userEmail'],
      turfId: map['turfId'] ?? '',
      turfName: map['turfName'] ?? '',
      facilityId: map['facilityId'],
      facilityName: map['facilityName'],
      isHalfBooking: map['isHalfBooking'] ?? false,
      sport: map['sport'],
      date: map['date'] != null ? parseDate(map['date']) : DateTime.now(),
      timeSlot: map['timeSlot'] ?? '',
      duration: map['duration'] ?? 60,
      amount: map['amount'] != null ? (map['amount']).toDouble() : 
              map['totalPrice'] != null ? (map['totalPrice']).toDouble() : 0.0,
      totalPrice: map['totalPrice'] != null ? (map['totalPrice']).toDouble() : 
                 map['amount'] != null ? (map['amount']).toDouble() : 0.0,
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'],
      courtNumber: map['courtNumber'],
      sideSize: map['sideSize'],
      createdAt: map['createdAt'] != null ? 
                (map['createdAt'] is Timestamp ? 
                 (map['createdAt'] as Timestamp).toDate() : null) : null,
      cancelledAt: map['cancelledAt'] != null ? 
                 (map['cancelledAt'] is Timestamp ? 
                  (map['cancelledAt'] as Timestamp).toDate() : null) : null,
      bookingTime: map['bookingTime'] != null ? 
                 (map['bookingTime'] is Timestamp ? 
                  (map['bookingTime'] as Timestamp).toDate() : null) : null,
      paymentId: map['paymentId'],
      paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'turfId': turfId,
      'turfName': turfName,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'isHalfBooking': isHalfBooking,
      'sport': sport,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'duration': duration,
      'courtNumber': courtNumber,
      'sideSize': sideSize,
      'amount': amount,
      'totalPrice': totalPrice ?? amount,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'bookingTime': bookingTime?.toIso8601String(),
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
    };
  }
}