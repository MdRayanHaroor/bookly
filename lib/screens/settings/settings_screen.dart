import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookly/providers/theme_provider.dart';
import 'package:bookly/screens/profile/profile_screen.dart';
import 'package:bookly/screens/settings/privacy_screen.dart';
import 'package:bookly/screens/settings/about_screen.dart';
import 'package:bookly/screens/settings/help_support_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Detect if we're in dark mode
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    // Define theme-adaptive colors
    final primaryTextColor = isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
    final dividerColor = isDarkTheme ? Colors.grey[800] : Colors.grey[300];
    final iconColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // App Theme Section
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
            child: _buildSectionHeader(context, 'Appearance'),
          ),
          
          // Theme Toggle
          _buildThemeToggle(context),
          
          Divider(color: dividerColor),
          
          // Account Section
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
            child: _buildSectionHeader(context, 'Account'),
          ),
          
          // Account Settings Options
          ListTile(
            leading: Icon(Icons.person_outline, color: iconColor),
            title: Text('Profile', style: TextStyle(color: primaryTextColor)),
            trailing: Icon(Icons.chevron_right, color: secondaryTextColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          
          ListTile(
            leading: Icon(Icons.privacy_tip, color: iconColor),
            title: Text('Privacy Policy', style: TextStyle(color: primaryTextColor)),
            subtitle: Text('Read our privacy policy', style: TextStyle(color: secondaryTextColor)),
            trailing: Icon(Icons.chevron_right, color: secondaryTextColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyScreen()),
              );
            },
          ),
          
          Divider(color: dividerColor),
          
          // Information Section
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
            child: _buildSectionHeader(context, 'Information'),
          ),
          
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: Text('About Us', style: TextStyle(color: primaryTextColor)),
            subtitle: Text('About Bookly app', style: TextStyle(color: secondaryTextColor)),
            trailing: Icon(Icons.chevron_right, color: secondaryTextColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
          
          ListTile(
            leading: Icon(Icons.help_outline, color: iconColor),
            title: Text('Help & Support', style: TextStyle(color: primaryTextColor)),
            subtitle: Text('Get assistance and support', style: TextStyle(color: secondaryTextColor)),
            trailing: Icon(Icons.chevron_right, color: secondaryTextColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSupportScreen()),
              );
            },
          ),
          
          Divider(color: dividerColor),
          
          // App version info at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Bookly - Sports Venue Booking App',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
  
  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
    
    return SwitchListTile(
      title: Text(
        'Dark Mode',
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        'Switch between light and dark themes',
        style: TextStyle(
          color: secondaryTextColor,
        ),
      ),
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).primaryColor,
      ),
      value: themeProvider.isDarkMode,
      onChanged: (_) {
        themeProvider.toggleTheme();
      },
    );
  }
}