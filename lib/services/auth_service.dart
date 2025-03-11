import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user id
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      throw e;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      print('Starting user registration for $email');
      
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('User created in Firebase Auth with ID: ${userCredential.user?.uid}');

      // Make sure we have a valid user before proceeding
      if (userCredential.user == null) {
        throw Exception('User registration failed: user is null');
      }

      // Save additional user data to Firestore
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'profilePic': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('User data saved to Firestore successfully');
      } catch (firestoreError) {
        print('Error saving user data to Firestore: $firestoreError');
        // Don't throw here, as the auth user was created successfully
        // In a production app, you might want to delete the auth user or retry
      }

      // Update display name in Firebase Auth
      try {
        await userCredential.user!.updateDisplayName(name);
        print('Display name updated in Firebase Auth');
      } catch (updateError) {
        print('Error updating display name: $updateError');
        // Don't throw, as this is not critical
      }

      return userCredential;
    } catch (e) {
      print('Error during registration: $e');
      throw e;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUserId == null) {
      print('No current user ID available');
      return null;
    }
    
    try {
      print('Fetching user data for ID: $currentUserId');
      final docSnapshot = await _firestore.collection('users').doc(currentUserId).get();
      
      if (docSnapshot.exists) {
        print('User data found in Firestore');
        return docSnapshot.data();
      } else {
        print('No user document found in Firestore for ID: $currentUserId');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }
}