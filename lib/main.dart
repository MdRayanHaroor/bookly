import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:bookly/screens/auth/login_screen.dart';
import 'package:bookly/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookly/providers/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
      // Firebase already initialized, get the existing instance
      Firebase.app();
    } else {
      // If it's a different error, rethrow it
      rethrow;
    }
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Bookly',
          themeMode: themeProvider.themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  return HomeScreen();
                }
                return LoginScreen();
              }
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      }
    );
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
      primaryColor: Color(0xFF00C853),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF00C853),
        secondary: Color(0xFF00E676),
        background: Colors.white,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      dividerColor: Colors.grey[300],
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      ),
      appBarTheme: AppBarTheme(
        color: Color(0xFF00C853),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.green,
      primaryColor: Color(0xFF00C853),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF00C853),
        secondary: Color(0xFF00E676),
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
      dividerColor: Colors.grey[800],
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
      ),
      appBarTheme: AppBarTheme(
        color: Color(0xFF1E1E1E),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}