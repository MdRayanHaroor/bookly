import 'package:flutter/material.dart';
import 'package:bookly/services/auth_service.dart';
import 'package:bookly/services/email_service.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _prefillUserData();
    
    // Initialize email service
    // Note: In a real app, store these credentials securely, not hardcoded
    // You can use environment variables or a secure storage solution
    EmailService.initGmail(
      username: 'mohammedrayan977@gmail.com',
      password: 'rsxo tgqe mkwf xpbw',
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _prefillUserData() async {
    if (!mounted) return;
    
    try {
      final userData = await _authService.getUserData();
      
      if (!mounted) return;
      
      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Send email using EmailService
      await EmailService.sendContactForm(
        name: _nameController.text,
        email: _emailController.text,
        subject: _subjectController.text,
        message: _messageController.text,
        recipientEmail: 'mohammedrayan977@gmail.com',
      );
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your message has been sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form after successful submission
      _subjectController.clear();
      _messageController.clear();
      
    } catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Icon(
                  Icons.support_agent,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Get In Touch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Feel free to reach out with any questions or feedback',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 32),
              
              // Contact Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Subject Field
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: Icon(Icons.subject),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Message Field
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        prefixIcon: Icon(Icons.message),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Send Message'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Alternative contact methods
              Text(
                'Other Ways to Reach Us',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildContactMethod(Icons.email, 'Email', 'mohammedrayan977@gmail.com'),
              SizedBox(height: 8),
              _buildContactMethod(Icons.phone, 'Phone', '+91 7829751480'),
              SizedBox(height: 8),
              //_buildContactMethod(Icons.location_on, 'Address', '123 Main Street, City, State, Country'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContactMethod(IconData icon, String title, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}