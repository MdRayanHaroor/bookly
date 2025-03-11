import 'package:flutter/material.dart';
import 'package:bookly/models/turf.dart';
import 'package:bookly/screens/booking/booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Review model class
class TurfReview {
  final String id;
  final String userId;
  final String userName;
  final String turfId;
  final String comment;
  final double rating;
  final DateTime createdAt;

  TurfReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.turfId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory TurfReview.fromMap(Map<String, dynamic> map, String id) {
    // Handle different timestamp formats
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is DateTime) {
        return timestamp;
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return DateTime.now(); // Fallback
      }
    }
    
    return TurfReview(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      turfId: map['turfId'] ?? '',
      comment: map['comment'] ?? '',
      rating: map['rating'] is int 
          ? (map['rating'] as int).toDouble() 
          : (map['rating'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null 
          ? parseTimestamp(map['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'turfId': turfId,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class TurfDetailsScreen extends StatefulWidget {
  final Turf turf;

  TurfDetailsScreen({required this.turf});

  @override
  _TurfDetailsScreenState createState() => _TurfDetailsScreenState();
}

class _TurfDetailsScreenState extends State<TurfDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<TurfReview> _reviews = [];
  bool _isLoadingReviews = true;
  double _avgRating = 0.0;
  
  // Review form controllers
  final _commentController = TextEditingController();
  double _userRating = 0;
  bool _isSubmittingReview = false;
  
  // User data
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    // Check if turf has an ID before fetching reviews
    if (widget.turf.id != null && widget.turf.id.isNotEmpty) {
      print('Turf ID found: ${widget.turf.id}');
      _fetchReviews();
      _loadUserData();
    } else {
      print('Warning: Turf ID is missing or empty!');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  // Load the user's actual profile data
  Future<void> _loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    
    try {
      // Fetch the user document from the users collection
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        
        // Use the name from the user's profile document
        if (userData.containsKey('name') && userData['name'] != null) {
          setState(() {
            _userName = userData['name'];
          });
          print('Loaded username: $_userName');
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Fetch reviews from Firestore
  Future<void> _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      // Debug print to check turf id
      print('Fetching reviews for turf ID: ${widget.turf.id}');
      
      final snapshot = await _firestore
          .collection('reviews')
          .where('turfId', isEqualTo: widget.turf.id)
          .orderBy('createdAt', descending: true)
          .get();

      print('Number of reviews fetched: ${snapshot.docs.length}');
      
      // Debug print first document if available
      if (snapshot.docs.isNotEmpty) {
        print('First review data: ${snapshot.docs.first.data()}');
      }

      final reviews = snapshot.docs
          .map((doc) => TurfReview.fromMap(doc.data(), doc.id))
          .toList();

      // Calculate average rating
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += review.rating;
      }
      
      setState(() {
        _reviews = reviews;
        _avgRating = reviews.isEmpty ? 0 : totalRating / reviews.length;
        _isLoadingReviews = false;
      });
      
      // Debug print after setting state
      print('Reviews loaded: ${_reviews.length} reviews, avg rating: $_avgRating');
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  // Submit a new review
  Future<void> _submitReview() async {
    // Validate user is logged in
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to submit a review')),
      );
      return;
    }

    // Validate rating
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    // Validate comment
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a comment')),
      );
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      // Debug print to check turf ID
      print('Adding review for turf ID: ${widget.turf.id}');
      print('Using username: $_userName');
      
      // Create new review
      final newReview = TurfReview(
        id: '', // Will be assigned by Firestore
        userId: currentUser.uid,
        userName: _userName, // Use the name from user's profile, not displayName
        turfId: widget.turf.id,
        comment: comment,
        rating: _userRating,
        createdAt: DateTime.now(),
      );

      // Print review data for debugging
      print('Review data to save: ${newReview.toMap()}');

      // Add to Firestore
      final docRef = await _firestore.collection('reviews').add(newReview.toMap());
      print('Review saved with ID: ${docRef.id}');

      // Reset form and refresh reviews
      setState(() {
        _commentController.clear();
        _userRating = 0;
        _isSubmittingReview = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for your review!')),
      );

      // Refresh reviews list
      await _fetchReviews();
    } catch (e) {
      print('Error submitting review: $e');
      setState(() {
        _isSubmittingReview = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review. Please try again.')),
      );
    }
  }

  // Show review dialog
  void _showReviewDialog() {
    // Check if user is logged in
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to leave a review'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              // Navigate to login screen (implement this)
              // Navigator.pushNamed(context, '/login');
            },
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate & Review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tell us about your experience at ${widget.turf.name}'),
              SizedBox(height: 16),
              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _userRating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _userRating = index + 1;
                      });
                      Navigator.of(context).pop();
                      _showReviewDialog(); // Reopen the dialog with updated state
                    },
                  );
                }),
              ),
              SizedBox(height: 16),
              // Comment text field
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Your Review',
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitReview();
            },
            child: Text('SUBMIT'),
          ),
        ],
      ),
    );
  }

  String _getImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://placehold.co/400x200?text=No+Image';
    }
    // Check if using the placeholder URL format from Firebase
    if (url.contains('your-project-id')) {
      return 'https://placehold.co/400x200?text=Facility+Image';
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.turf.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      // Rating badge
                      if (_avgRating > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                _avgRating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
                  
                  // Reviews section
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.rate_review),
                        label: Text('Write Review'),
                        onPressed: _showReviewDialog,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // Reviews list
                  if (_isLoadingReviews)
                    Center(child: CircularProgressIndicator())
                  else if (_reviews.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No reviews yet. Be the first to review!',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        return _buildReviewCard(_reviews[index], isDarkTheme);
                      },
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
  
  // Method to build a review card
  Widget _buildReviewCard(TurfReview review, bool isDarkTheme) {
    final primaryTextColor = isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(review.userName.isNotEmpty 
                      ? review.userName[0].toUpperCase() 
                      : 'U'),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(review.createdAt),
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Star rating
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              review.comment,
              style: TextStyle(color: secondaryTextColor),
            ),
          ],
        ),
      ),
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