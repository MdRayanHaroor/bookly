import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  // Handle URL actions with a snackbar instead of launching URLs
  void _handleUrlAction(BuildContext context, String type, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would open $type: $value'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
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
    final cardBgColor = isDarkTheme ? Colors.grey[850] : Colors.white;
    final cardBorderColor = isDarkTheme ? Colors.grey[700] : Colors.grey[300];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // App Name
            Text(
              'Bookly',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'Sports Venue Booking App',
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
            SizedBox(height: 32),
            
            // About Us description
            Card(
              color: cardBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: cardBorderColor!),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bookly aims to connect sports enthusiasts with the best venues and facilities. We make booking sports facilities simple, convenient, and hassle-free.',
                      style: TextStyle(
                        color: primaryTextColor,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'What We Offer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildFeatureItem(
                      Icons.search,
                      'Discover sports venues near you',
                      primaryTextColor,
                    ),
                    _buildFeatureItem(
                      Icons.event_available,
                      'Easy booking and scheduling',
                      primaryTextColor,
                    ),
                    _buildFeatureItem(
                      Icons.payment,
                      'Secure payment processing',
                      primaryTextColor,
                    ),
                    _buildFeatureItem(
                      Icons.star,
                      'Rate and review facilities',
                      primaryTextColor,
                    ),
                    _buildFeatureItem(
                      Icons.group,
                      'Invite friends to play',
                      primaryTextColor,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            
            // Development Team
            Text(
              'Development Team',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildTeamMember(
                  'Harur Mohammed Rayan',
                  'Full Stack Developer',
                  Icons.engineering,
                  primaryTextColor,
                  secondaryTextColor,
                  cardBgColor,
                  cardBorderColor,
                  context,
                ),
                // _buildTeamMember(
                //   'Jane Smith',
                //   'UI/UX Designer',
                //   Icons.design_services,
                //   primaryTextColor,
                //   secondaryTextColor,
                //   cardBgColor,
                //   cardBorderColor,
                //   context,
                // ),
                // _buildTeamMember(
                //   'Mike Johnson',
                //   'Product Manager',
                //   Icons.business_center,
                //   primaryTextColor,
                //   secondaryTextColor,
                //   cardBgColor,
                //   cardBorderColor,
                //   context,
                // ),
              ],
            ),
            SizedBox(height: 32),
            
            // Contact & Social Media (without url_launcher)
            Text(
              'Connect With Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.language),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _handleUrlAction(context, 'website', 'bookly.com'),
                ),
                IconButton(
                  icon: Icon(Icons.facebook),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _handleUrlAction(context, 'social media', 'facebook.com/booklyapp'),
                ),
                IconButton(
                  icon: Icon(Icons.email),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _handleUrlAction(context, 'email', 'contact@bookly.com'),
                ),
                IconButton(
                  icon: Icon(Icons.phone),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _handleUrlAction(context, 'phone', '+1234567890'),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Copyright
            Text(
              '© 2025 Bookly. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeamMember(
    String name, 
    String role, 
    IconData icon,
    Color nameColor,
    Color? roleColor,
    Color? cardColor,
    Color? borderColor,
    BuildContext context,
  ) {
    return Container(
      width: 140,
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                radius: 30,
                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: nameColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  color: roleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}