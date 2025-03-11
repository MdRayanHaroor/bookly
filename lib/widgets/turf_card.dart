import 'package:flutter/material.dart';
import 'package:bookly/models/turf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TurfCard extends StatefulWidget {
  final Turf turf;
  final VoidCallback onTap;

  TurfCard({
    required this.turf,
    required this.onTap,
  });

  @override
  _TurfCardState createState() => _TurfCardState();
}

class _TurfCardState extends State<TurfCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _rating = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    if (widget.turf.id == null || widget.turf.id.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('turfId', isEqualTo: widget.turf.id)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _rating = 0;
          _isLoading = false;
        });
        return;
      }

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('rating')) {
          double rating = data['rating'] is int
              ? (data['rating'] as int).toDouble()
              : (data['rating'] ?? 0.0).toDouble();
          totalRating += rating;
        }
      }

      setState(() {
        _rating = snapshot.docs.isEmpty ? 0 : totalRating / snapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading rating for turf ${widget.turf.id}: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildRatingStars() {
    if (_isLoading) {
      return Container(
        width: 60,
        height: 14,
        child: LinearProgressIndicator(
          backgroundColor: Colors.grey[300],
        ),
      );
    }

    if (_rating == 0) {
      return Text(
        'No ratings yet',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          double difference = _rating - index;
          IconData icon;
          
          if (difference >= 1) {
            icon = Icons.star; // Full star
          } else if (difference > 0) {
            icon = Icons.star_half; // Half star
          } else {
            icon = Icons.star_border; // Empty star
          }
          
          return Icon(
            icon,
            color: Colors.amber,
            size: 14,
          );
        }),
        
        SizedBox(width: 4),
        
        Text(
          _rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect if we're in dark mode
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    // Define theme-adaptive colors
    final primaryTextColor = isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: widget.turf.imageUrls.isNotEmpty
                  ? Image.network(
                      widget.turf.imageUrls[0],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: isDarkTheme ? Colors.grey[800] : Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.image, 
                              size: 50, 
                              color: isDarkTheme ? Colors.grey[600] : Colors.grey[500],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 150,
                      color: isDarkTheme ? Colors.grey[800] : Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image, 
                          size: 50, 
                          color: isDarkTheme ? Colors.grey[600] : Colors.grey[500],
                        ),
                      ),
                    ),
            ),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.turf.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      // Rating stars
                      _buildRatingStars(),
                    ],
                  ),
                  
                  SizedBox(height: 4),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: secondaryTextColor),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.turf.location,
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Sports tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.turf.sports.map((sport) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}