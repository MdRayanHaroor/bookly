// services/turf_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookly/models/turf.dart';

class TurfService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all turfs
  Future<List<Turf>> getTurfs() async {
    try {
      print("Fetching turfs from Firestore...");
      final snapshot = await _firestore.collection('turfs').get();
      
      print("Got ${snapshot.docs.length} documents from Firestore");
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print("Document ID: ${doc.id}");
        print("Document data: $data");
        
        // Add the document ID to the data map if '_id' isn't already present
        if (!data.containsKey('_id')) {
          data['_id'] = doc.id;
        }
        
        try {
          return Turf.fromMap(data, doc.id);
        } catch (e) {
          print("Error parsing turf document: $e");
          return null;
        }
      }).where((turf) => turf != null).cast<Turf>().toList();
    } catch (e) {
      print("Error fetching turfs: $e");
      return []; // Return empty list on error
    }
  }

  // Get turf by id
  Future<Turf> getTurfById(String id) async {
    // Get turf from Firestore
    final doc = await _firestore.collection('turfs').doc(id).get();

    if (!doc.exists) {
      throw Exception('Turf not found');
    }

    // Convert to Turf object
    return Turf.fromMap(doc.data()!, doc.id);
  }
  
  // Get all facilities for a specific sport
  Future<List<SportFacility>> getFacilitiesForSport(String sport) async {
    try {
      final snapshot = await _firestore.collection('turfs').get();
      
      List<SportFacility> facilities = [];
      
      for (var doc in snapshot.docs) {
        try {
          final turf = Turf.fromMap(doc.data(), doc.id);
          
          // Find facilities that support this sport
          final sportFacilities = turf.sportFacilities.where(
            (facility) => facility.supportedSports.contains(sport)
          ).toList();
          
          facilities.addAll(sportFacilities);
        } catch (e) {
          print("Error parsing turf for facilities: $e");
        }
      }
      
      return facilities;
    } catch (e) {
      print("Error fetching facilities for sport $sport: $e");
      return [];
    }
  }
}