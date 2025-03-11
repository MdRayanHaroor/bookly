import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
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
    final expandedColor = isDarkTheme ? Colors.grey[800] : Colors.grey[200];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support options
            Card(
              color: cardBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: cardBorderColor!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildContactOption(
                      icon: Icons.email,
                      title: 'Email Support',
                      subtitle: 'mohammedrayan977@gmail.com',
                      onTap: () => _handleUrlAction(context, 'email', 'support@bookly.com'),
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      context: context,
                    ),
                    SizedBox(height: 16),
                    _buildContactOption(
                      icon: Icons.phone,
                      title: 'Phone Support',
                      subtitle: '+91 7829751480',
                      onTap: () => _handleUrlAction(context, 'phone', '+1 (234) 567-890'),
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      context: context,
                    ),
                    SizedBox(height: 16),
                    _buildContactOption(
                      icon: Icons.language,
                      title: 'Help Center',
                      subtitle: 'Visit our knowledge base',
                      onTap: () => _handleUrlAction(context, 'website', 'bookly.com/help'),
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: 16),
            
            // FAQ items
            _buildFaqItem(
              'How do I book a sports venue?',
              'To book a sports venue, browse the available turfs on the home screen, select the one you want, choose your preferred date and time slot, and complete the payment process.',
              primaryTextColor,
              secondaryTextColor,
              expandedColor,
              context,
            ),
            _buildFaqItem(
              'Can I cancel my booking?',
              'Yes, you can cancel your booking from the "My Bookings" section. Please note that cancellation policies vary by venue, and cancellation fees may apply depending on how close to the booking time you cancel.',
              primaryTextColor,
              secondaryTextColor,
              expandedColor,
              context,
            ),
            _buildFaqItem(
              'How do I pay for my booking?',
              'We support various payment methods including credit/debit cards, UPI, and wallet payments. All payments are securely processed through our payment gateway.',
              primaryTextColor,
              secondaryTextColor,
              expandedColor,
              context,
            ),
            _buildFaqItem(
              'What if the venue is not as described?',
              'If you find that a venue doesn\'t match its description or there are issues with your booking, please contact our support team immediately. We\'ll work with the venue to resolve the issue or provide a refund if necessary.',
              primaryTextColor,
              secondaryTextColor,
              expandedColor,
              context,
            ),
            _buildFaqItem(
              'Can I invite friends to join my booking?',
              'Yes! After booking a venue, you can share the booking details with your friends directly from the app using the "Share" button on your booking details.',
              primaryTextColor,
              secondaryTextColor,
              expandedColor,
              context,
            ),
            _buildFaqItem(
              'What if I\'m running late for my booking?',
              'It\'s best to contact the venue directly if you\'re running late. Most venues have a grace period, but policies vary. You can find the venue\'s contact information in your booking details.',
              primaryTextColor,
              secondaryTextColor,
              expandedColor,
              context,
            ),
            
            SizedBox(height: 24),
            
            // Feedback section
            Card(
              color: cardBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: cardBorderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'We\'re always looking to improve. Let us know your thoughts about the app!',
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Show feedback dialog instead of launching email
                        _showFeedbackDialog(context);
                      },
                      icon: Icon(Icons.feedback, color: Colors.white),
                      label: Text('Submit Feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFeedbackDialog(BuildContext context) {
    // Detect if we're in dark mode
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final inputBorderColor = isDarkTheme ? Colors.grey[700] : Colors.grey[300];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your feedback',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Feedback submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
    required Color primaryTextColor,
    required Color? secondaryTextColor,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFaqItem(
    String question,
    String answer,
    Color questionColor,
    Color? answerColor,
    Color? expandedColor,
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: questionColor,
          ),
        ),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.topLeft,
        backgroundColor: expandedColor,
        children: [
          Text(
            answer,
            style: TextStyle(
              color: answerColor,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}