// widgets/turf_card.dart
import 'package:flutter/material.dart';
import 'package:bookly/models/turf.dart';

class TurfCard extends StatelessWidget {
  final Turf turf;
  final VoidCallback onTap;

  const TurfCard({
    Key? key,
    required this.turf,
    required this.onTap,
  }) : super(key: key);

  // Helper function to safely get image URL or return placeholder
  String _getImageUrl() {
    if (turf.imageUrls.isNotEmpty) {
      final url = turf.imageUrls[0];
      // Check if using the placeholder URL format from Firebase
      if (url.contains('your-project-id')) {
        // Return a valid placeholder instead
        return 'https://via.placeholder.com/400x200?text=Turf+Image';
      }
      return url;
    }
    return 'https://via.placeholder.com/400x200?text=No+Image';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Turf image with better error handling
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                _getImageUrl(),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.grey[600]),
                          SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Turf details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Turf name
                  Text(
                    turf.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          turf.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  
                  // Available sports
                  Text(
                    'Available Sports:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Sports tags
                  turf.sports.isNotEmpty
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: turf.sports.map((sport) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                sport,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : Text(
                          'No sports information available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                  
                  // Amenities
                  SizedBox(height: 12),
                  if (turf.amenities.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            turf.amenities.join(', '),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}