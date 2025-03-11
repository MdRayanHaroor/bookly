// models/turf.dart
class Turf {
  final String id;
  final String name;
  final String location;
  final String description;
  final List<String> amenities;
  final List<int> availableSizes;
  final List<String> imageUrls;
  final List<String> sports; // General list of sports offered
  final List<SportFacility> sportFacilities; // Detailed sport facilities with pricing

  Turf({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.amenities,
    required this.availableSizes,
    required this.imageUrls,
    this.sports = const [],
    this.sportFacilities = const [],
  });

  factory Turf.fromMap(Map<String, dynamic> map, String id) {
    // Parse sport facilities
    List<SportFacility> facilities = [];
    if (map['sportsFacilities'] != null) {
      facilities = List<SportFacility>.from(
        (map['sportsFacilities'] as List).map(
          (facility) => SportFacility.fromMap(facility),
        ),
      );
    }

    return Turf(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      availableSizes: List<int>.from(map['availableSizes'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      sports: List<String>.from(map['sports'] ?? []),
      sportFacilities: facilities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'amenities': amenities,
      'availableSizes': availableSizes,
      'imageUrls': imageUrls,
      'sports': sports,
      'sportFacilities': sportFacilities.map((facility) => facility.toMap()).toList(),
    };
  }
}

class SportFacility {
  final String facilityId;
  final String facilityName; // e.g., "Main Football Turf", "Badminton Court 1"
  final String facilityType; // e.g., "Turf", "Court", "Table"
  final List<String> supportedSports; // Sports that can be played on this facility
  final double pricePerHour;
  final bool canBeSplit; // Whether the facility can be split (half-court booking)
  final double splitPricePerHour; // Price when booking half the facility
  final int availableUnits; // Number of this type of facility (e.g., 2 badminton courts)
  final String? imageUrl; // Specific image for this facility

  SportFacility({
    required this.facilityId,
    required this.facilityName,
    required this.facilityType,
    required this.supportedSports,
    required this.pricePerHour,
    this.canBeSplit = false,
    this.splitPricePerHour = 0,
    this.availableUnits = 1,
    this.imageUrl,
  });

  factory SportFacility.fromMap(Map<String, dynamic> map) {
    return SportFacility(
      facilityId: map['facilityId'] ?? '',
      facilityName: map['facilityName'] ?? '',
      facilityType: map['facilityType'] ?? '',
      supportedSports: List<String>.from(map['supportedSports'] ?? []),
      pricePerHour: (map['pricePerHour'] ?? 0).toDouble(),
      canBeSplit: map['canBeSplit'] ?? false,
      splitPricePerHour: (map['splitPricePerHour'] ?? 0).toDouble(),
      availableUnits: map['availableUnits'] ?? 1,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'facilityId': facilityId,
      'facilityName': facilityName,
      'facilityType': facilityType,
      'supportedSports': supportedSports,
      'pricePerHour': pricePerHour,
      'canBeSplit': canBeSplit,
      'splitPricePerHour': splitPricePerHour,
      'availableUnits': availableUnits,
      'imageUrl': imageUrl,
    };
  }
}