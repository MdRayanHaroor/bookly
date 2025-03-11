import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // SMTP Server configuration
  static SmtpServer? _smtpServer;
  
  // Initialize SMTP server with credentials
  static void init({
    required String username,
    required String password,
    required String smtpHost,
    required int smtpPort,
    bool ssl = true
  }) {
    _smtpServer = SmtpServer(
      smtpHost,
      port: smtpPort,
      ssl: ssl,
      username: username,
      password: password,
    );
  }
  
  // Initialize for Gmail
  static void initGmail({required String username, required String password}) {
    _smtpServer = gmail(username, password);
  }
  
  // Send a contact form submission
  static Future<bool> sendContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
    required String recipientEmail,
  }) async {
    if (_smtpServer == null) {
      throw Exception('SMTP server not initialized. Call init() or initGmail() first.');
    }
    
    final emailMessage = Message()
      ..from = Address(email, name)
      ..recipients.add(recipientEmail)
      ..subject = 'Bookly Contact: $subject'
      ..text = '''
From: $name ($email)

$message
''';
    
    try {
      final sendReport = await send(emailMessage, _smtpServer!);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent. Error: $e');
      throw Exception('Failed to send email: ${e.toString()}');
    }
  }
  
  // Send a custom email
  static Future<bool> sendEmail({
    required String fromEmail,
    required String fromName,
    required List<String> recipients,
    required String subject,
    required String body,
    List<String> ccRecipients = const [],
    List<String> bccRecipients = const [],
  }) async {
    if (_smtpServer == null) {
      throw Exception('SMTP server not initialized. Call init() or initGmail() first.');
    }
    
    final emailMessage = Message()
      ..from = Address(fromEmail, fromName)
      ..recipients.addAll(recipients)
      ..ccRecipients.addAll(ccRecipients)
      ..bccRecipients.addAll(bccRecipients)
      ..subject = subject
      ..text = body;
    
    try {
      final sendReport = await send(emailMessage, _smtpServer!);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent. Error: $e');
      throw Exception('Failed to send email: ${e.toString()}');
    }
  }
}