import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Detect if we're in dark mode
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    // Define theme-adaptive colors
    final primaryTextColor = isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.grey[700];
    final headingColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: March 10, 2025',
              style: TextStyle(
                color: secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24),
            
            _buildSection(
              'Introduction',
              'Welcome to Bookly, a sports venue booking app. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              primaryTextColor,
              secondaryTextColor,
              headingColor,
            ),
            
            _buildSection(
              'Information We Collect',
              'We may collect information that you provide to us, including:\n\n'
              '• Personal information (name, email address, phone number)\n'
              '• Account credentials\n'
              '• Payment information\n'
              '• Booking history and preferences\n'
              '• Location data (with your permission)\n'
              '• Device information',
              primaryTextColor,
              secondaryTextColor,
              headingColor,
            ),
            
            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Facilitate and process bookings\n'
              '• Create and maintain your account\n'
              '• Process payments\n'
              '• Communicate with you about bookings and updates\n'
              '• Improve our services\n'
              '• Comply with legal obligations',
              primaryTextColor,
              secondaryTextColor,
              headingColor,
            ),
            
            _buildSection(
              'Sharing Your Information',
              'We may share your information with:\n\n'
              '• Sports venues and facility providers to facilitate bookings\n'
              '• Payment processors\n'
              '• Service providers who assist us in operating our app\n'
              '• Legal authorities when required by law',
              primaryTextColor,
              secondaryTextColor,
              headingColor,
            ),
            
            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your personal information. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
              primaryTextColor,
              secondaryTextColor,
              headingColor,
            ),
            
            _buildSection(
              'Your Rights',
              'Depending on your location, you may have certain rights regarding your personal information, including:\n\n'
              '• Access to your personal information\n'
              '• Correction of inaccurate information\n'
              '• Deletion of your information\n'
              '• Objection to certain processing activities\n'
              '• Data portability',
              primaryTextColor,
              secondaryTextColor,
              headingColor,
            ),
            
            _buildSection(
              'Changes to This Policy',
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
              primaryTextColor,
              secondaryTextColor,
              headingColor,
            ),
            
            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at:\n\nsupport@bookly.com',
              primaryTextColor,
              secondaryTextColor,
              headingColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content, Color titleColor, Color? contentColor, Color headingColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: contentColor,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}