import 'package:flutter/material.dart';
import 'package:bookly/models/turf.dart';
import 'package:bookly/screens/home/turf_details_screen.dart';
import 'package:bookly/screens/profile/my_bookings_screen.dart';
import 'package:bookly/screens/settings/settings_screen.dart';
import 'package:bookly/screens/profile/profile_screen.dart';
import 'package:bookly/screens/contact/contact_screen.dart';
import 'package:bookly/services/auth_service.dart';
import 'package:bookly/services/turf_service.dart';
import 'package:bookly/widgets/turf_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TurfService _turfService = TurfService();
  final AuthService _authService = AuthService();
  List<Turf> _turfs = [];
  List<Turf> _filteredTurfs = [];
  bool _isLoading = true; // Set to true initially
  int _selectedIndex = 0;
  bool _isListView = true;
  String _searchQuery = '';
  Set<String> _selectedFilters = {};
  String _userName = 'User';
  String _userEmail = '';
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    // Add observer to detect when app resumes
    WidgetsBinding.instance.addObserver(this);
    _loadTurfs();
    _loadUserData();
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app resumes
    if (state == AppLifecycleState.resumed) {
      _loadTurfs();
    }
  }

  Future<void> _loadTurfs() async {
    // Make sure we start with loading state
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final turfs = await _turfService.getTurfs();
      
      // Check mounted before updating state
      if (!mounted) return;
      
      setState(() {
        _turfs = turfs;
        _filteredTurfs = turfs;
        _isLoading = false;
      });
    } catch (e) {
      // Check mounted before updating state
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load turfs: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    try {
      final userData = await _authService.getUserData();
      
      if (!mounted) return;
      
      setState(() {
        _isLoadingUserData = false;
        if (userData != null) {
          _userName = userData['name'] ?? 'User';
          _userEmail = userData['email'] ?? '';
        }
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingUserData = false;
      });
      print('Error loading user data: $e');
    }
  }

  void _filterTurfs() {
    // Only update state if the widget is still mounted
    if (!mounted) return;
    
    setState(() {
      _filteredTurfs = _turfs.where((turf) {
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final name = turf.name.toLowerCase();
          final location = turf.location.toLowerCase();
          final query = _searchQuery.toLowerCase();
          if (!name.contains(query) && !location.contains(query)) {
            return false;
          }
        }

        // Apply sports filters
        if (_selectedFilters.isNotEmpty) {
          // Check if turf has any of the selected sports
          bool hasSport = false;
          for (String sport in _selectedFilters) {
            if (turf.sports.contains(sport)) {
              hasSport = true;
              break;
            }
          }
          if (!hasSport) {
            return false;
          }
        }
        
        return true;
      }).toList();
    });
  }

  void _navigateToTurfDetails(Turf turf) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TurfDetailsScreen(turf: turf),
      ),
    ).then((_) {
      // Refresh the turfs data when returning from the details screen
      // This ensures ratings and reviews are up to date
      if (mounted) {
        _loadTurfs();
      }
    });
  }

  void _onItemTapped(int index) {
    // Check if the widget is still mounted
    if (!mounted) return;
    
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyBookingsScreen()),
        ).then((_) {
          // Check if the widget is still mounted before updating state
          if (mounted) {
            setState(() {
              _selectedIndex = 0;
            });
            // Refresh data when returning from bookings
            _loadTurfs();
          }
        });
      }
    }
  }

  Widget _buildDrawer() {
    // Detect if we're in dark mode
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final drawerTextColor = isDarkTheme ? Colors.white : Colors.black87;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                _isLoadingUserData
                    ? Container(
                        height: 14,
                        width: 100,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white30,
                          color: Colors.white70,
                        ),
                      )
                    : Text(
                        _userName,
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                if (_userEmail.isNotEmpty && !_isLoadingUserData)
                  Text(
                    _userEmail,
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Theme.of(context).primaryColor),
            title: Text('Profile', style: TextStyle(color: drawerTextColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              ).then((_) {
                // Reload user data when returning from profile screen
                _loadUserData();
                // Also refresh turfs as user profile might affect recommendations
                _loadTurfs();
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Theme.of(context).primaryColor),
            title: Text('Settings', style: TextStyle(color: drawerTextColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ).then((_) {
                // Settings might change display preferences, refresh
                if (mounted) setState(() {});
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_phone, color: Theme.of(context).primaryColor),
            title: Text('Contact Us', style: TextStyle(color: drawerTextColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: drawerTextColor)),
            onTap: () async {
              Navigator.pop(context);
              await _authService.signOut();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect if we're in dark mode
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    // Define theme-adaptive colors
    final primaryTextColor = isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
    final tertiaryTextColor = isDarkTheme ? Colors.grey[400] : Colors.grey[600];
    final cardBorderColor = isDarkTheme ? Colors.grey[700] : Colors.grey[300];
    final cardBgColor = isDarkTheme ? Colors.grey[850] : Colors.white;
    final noContentColor = isDarkTheme ? Colors.grey[400] : Colors.grey[700];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookly'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTurfs,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          hintText: 'Search turfs...',
                          hintStyle: TextStyle(color: secondaryTextColor),
                          prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cardBorderColor!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cardBorderColor!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _filterTurfs();
                        },
                      ),
                    ),
                    
                    // Filter options
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Common sports - add or remove as needed
                          ...['Football', 'Cricket', 'Badminton', 'Table Tennis', 'Snooker', '8 Ball Pool', 'Padel', 'Pickleball']
                              .map((sport) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: FilterChip(
                                      label: Text(sport),
                                      selected: _selectedFilters.contains(sport),
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      labelStyle: TextStyle(
                                        color: _selectedFilters.contains(sport) 
                                            ? Theme.of(context).primaryColor 
                                            : primaryTextColor,
                                      ),
                                      onSelected: (selected) {
                                        if (!mounted) return;
                                        setState(() {
                                          if (selected) {
                                            _selectedFilters.add(sport);
                                          } else {
                                            _selectedFilters.remove(sport);
                                          }
                                        });
                                        _filterTurfs();
                                      },
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Featured turfs section
                    if (_filteredTurfs.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              'Featured Turfs',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                // View all featured turfs
                              },
                              child: Text('See All'),
                            ),
                          ],
                        ),
                      ),
                      Container(
  height: 200,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _filteredTurfs.length > 3 ? 3 : _filteredTurfs.length,
    itemBuilder: (context, index) {
      final turf = _filteredTurfs[index];
      return Container(
        width: 280,
        margin: EdgeInsets.only(left: 16, right: index == (_filteredTurfs.length > 3 ? 2 : _filteredTurfs.length - 1) ? 16 : 0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorderColor!),
        ),
        child: GestureDetector(
          onTap: () => _navigateToTurfDetails(turf),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  turf.imageUrls.isNotEmpty 
                      ? turf.imageUrls[0]
                      : 'https://via.placeholder.com/280x120',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 110,
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            turf.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Rating stars using StreamBuilder
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('reviews')
                              .where('turfId', isEqualTo: turf.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                width: 50,
                                height: 10,
                                child: LinearProgressIndicator(
                                  backgroundColor: isDarkTheme ? Colors.grey[700] : Colors.grey[300],
                                ),
                              );
                            }
                            
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Text(
                                'New',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              );
                            }
                            
                            // Calculate average rating
                            double totalRating = 0;
                            snapshot.data!.docs.forEach((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              if (data.containsKey('rating')) {
                                double rating = data['rating'] is int
                                    ? (data['rating'] as int).toDouble()
                                    : (data['rating'] ?? 0.0).toDouble();
                                totalRating += rating;
                              }
                            });
                            
                            double avgRating = totalRating / snapshot.data!.docs.length;
                            
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                SizedBox(width: 2),
                                Text(
                                  avgRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: secondaryTextColor),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            turf.location,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Display sports instead of price
                    turf.sports != null && turf.sports.isNotEmpty
                    ? Container(
                        height: 16,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: turf.sports.length,
                          itemBuilder: (context, sportIndex) {
                            return Container(
                              margin: EdgeInsets.only(right: 4),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                turf.sports[sportIndex],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        'No sports info available',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
),
                    ],
                    
                    // All turfs section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'All Turfs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                    ),
                    
                    // Main list of turfs with fixed height
                    _filteredTurfs.isEmpty
                        ? Container(
                            height: 200,
                            child: Center(
                              child: Text(
                                'No turfs available', 
                                style: TextStyle(color: noContentColor),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filteredTurfs.length,
                            itemBuilder: (context, index) {
                              return TurfCard(
                                turf: _filteredTurfs[index],
                                onTap: () => _navigateToTurfDetails(_filteredTurfs[index]),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My Bookings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}