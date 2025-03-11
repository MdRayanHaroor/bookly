import 'package:flutter/material.dart';
import 'package:bookly/models/turf.dart';
import 'package:bookly/screens/booking/booking_screen.dart';

class TurfDetailsScreen extends StatefulWidget {
  final Turf turf;

  TurfDetailsScreen({required this.turf});

  @override
  _TurfDetailsScreenState createState() => _TurfDetailsScreenState();
}

class _TurfDetailsScreenState extends State<TurfDetailsScreen> {
  String _getImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x200?text=No+Image';
    }
    // Check if using the placeholder URL format from Firebase
    if (url.contains('your-project-id')) {
      return 'https://via.placeholder.com/400x200?text=Facility+Image';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    // Detect if we're in dark mode
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    // Define theme-adaptive colors
    final primaryTextColor = isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
    final tertiaryTextColor = isDarkTheme ? Colors.grey[400] : Colors.grey[600];
    
    final errorBgColor = isDarkTheme ? Colors.grey[800] : Colors.grey[300];
    final errorIconColor = isDarkTheme ? Colors.grey[500] : Colors.grey[600];
    
    final cardBgColor = isDarkTheme ? Colors.grey[850] : Colors.white;
    final cardSurfaceColor = isDarkTheme ? Colors.grey[800] : Colors.grey[200];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turf.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            Container(
              height: 200,
              child: PageView.builder(
                itemCount: widget.turf.imageUrls.length > 0 ? widget.turf.imageUrls.length : 1,
                itemBuilder: (context, index) {
                  return widget.turf.imageUrls.length > 0
                    ? Image.network(
                        _getImageUrl(widget.turf.imageUrls[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: errorBgColor,
                            child: Center(
                              child: Icon(Icons.broken_image, size: 50, color: errorIconColor),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: errorBgColor,
                        child: Center(
                          child: Text(
                            'No images available',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                        ),
                      );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Turf name and location
                  Text(
                    widget.turf.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: secondaryTextColor),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.turf.location,
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ),
                    ],
                  ),
                  
                  // Available sports section
                  SizedBox(height: 24),
                  Text(
                    'Available Sports',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Display sports as tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.turf.sports.map((sport) {
                      return Chip(
                        label: Text(sport),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  // About section
                  SizedBox(height: 24),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.turf.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                  
                  // Sport facilities with pricing
                  SizedBox(height: 24),
                  Text(
                    'Facilities & Pricing',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Display each sport facility as a card
                  ...widget.turf.sportFacilities.map((facility) => _buildFacilityCard(facility)).toList(),
                  
                  // If no facilities available yet
                  if (widget.turf.sportFacilities.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pricing Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please contact the venue for pricing details.',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Amenities section
                  SizedBox(height: 24),
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.turf.amenities.map((amenity) {
                      return Chip(
                        label: Text(
                          amenity,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.black : Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.green,
                      );
                    }).toList(),
                  ),
                  
                  // Available formats section (if applicable)
                  if (widget.turf.availableSizes.isNotEmpty) ...[
                    SizedBox(height: 24),
                    Text(
                      'Available Formats',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.turf.availableSizes.map((size) {
                        return Chip(
                          label: Text(
                            '$size-a-side',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.black : Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.blue,
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Add space at the bottom for the floating action button
                  SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(turf: widget.turf),
            ),
          );
        },
        label: Text('Book Now!'),
        icon: Icon(Icons.sports_soccer),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  // Method to build a facility card
  Widget _buildFacilityCard(SportFacility facility) {
    // Detect if we're in dark mode
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    // Define theme-adaptive colors
    final primaryTextColor = isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
    final errorBgColor = isDarkTheme ? Colors.grey[800] : Colors.grey[200];
    final priceColor = isDarkTheme ? Colors.green[400] : Colors.green[700];
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Facility image if available
          if (facility.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                _getImageUrl(facility.imageUrl),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: errorBgColor,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported, 
                        color: isDarkTheme ? Colors.grey[500] : Colors.grey
                      ),
                    ),
                  );
                },
              ),
            ),
            
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Facility name and type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        facility.facilityName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkTheme ? Colors.blue[900] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        facility.facilityType,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.blue[200] : Colors.blue[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                
                // Supported sports
                Text(
                  'Available for:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: facility.supportedSports.map((sport) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sport,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12),
                
                // Pricing information
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      size: 16,
                      color: priceColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${facility.pricePerHour.toStringAsFixed(0)} / hour',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: priceColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                // Split option if available
                if (facility.canBeSplit) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.view_week_outlined,
                        size: 16,
                        color: priceColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Half field: ₹${facility.splitPricePerHour.toStringAsFixed(0)} / hour',
                        style: TextStyle(
                          color: priceColor,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Available units if more than 1
                if (facility.availableUnits > 1) ...[
                  SizedBox(height: 4),
                  Text(
                    '${facility.availableUnits} units available',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: isDarkTheme ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}