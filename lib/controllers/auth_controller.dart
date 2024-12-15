import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zartek_task/common/local%20variables.dart';
import 'package:zartek_task/models/user_model.dart';

import '../views/screens/home_screen.dart';

final authControllerProvider = Provider((ref) {
  return AuthController(
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
    firestore: FirebaseFirestore.instance,
  );
});

class AuthController {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthController({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _googleSignIn = googleSignIn,
       _firestore = firestore {
    // Listen to auth state changes
    // _auth.authStateChanges().listen((User? user) {
    //   print('Auth state changed. User: ${user?.uid}'); // Debug log
    //   currentUserId = user?.uid;
    //   if (user != null) {
    //     _initializeUserDocument(user);
    //   } else {
    //     currentUserModel = null;
    //   }
    // });
  }

  User? get currentUser => _auth.currentUser;

  Future<void> _initializeUserDocument(User user) async {
    print('Initializing user document for: ${user.uid}'); // Debug log
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      print('Creating new user document for: ${user.uid}'); // Debug log
      currentUserModel = UserModel(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        cart: [], // Initialize with empty CartItem list
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        phone: user.phoneNumber ?? '',
        profilePic: user.photoURL ?? ''
      );
      await userDoc.set({
        ...currentUserModel!.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } else {
      print('Loading existing user document for: ${user.uid}'); // Debug log
      currentUserModel = UserModel.fromMap(docSnapshot.data()!);
    }
    print('User document initialized for: ${user.uid}'); // Debug log
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return _auth.currentUser;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        await _initializeUserDocument(user);
        currentUserId = user.uid;  // Set currentUserId
      }
      
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<void> verifyPhone(
    String phoneNumber, {
    required void Function(String verificationId) onCodeSent,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      throw e;
    }
  }

  Future<User?> verifyOtp(String verificationId, String smsCode,BuildContext context) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print(userCredential.user!.phoneNumber);
      if (userCredential.user != null) {
        await checkPhoneNumber(userCredential.user!.phoneNumber!, context, userCredential.user!);
        currentUserId = userCredential.user!.uid;  // Set currentUserId
      }

      return userCredential.user;
    } catch (e) {
      throw e;
    }
  }

  checkPhoneNumber(String phone,BuildContext context,User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        UserModel userModel = UserModel(
          id: user.uid, 
          name: user.displayName ?? '', 
          email: user.email ?? '', 
          cart: [], 
          createdAt: DateTime.now(), 
          lastLoginAt: DateTime.now(), 
          phone: phone, 
          profilePic: user.photoURL ?? ''
        );

        await userDoc.set(userModel.toMap());
        currentUserModel = userModel;
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        currentUserModel = UserModel.fromMap(docSnapshot.data()!);
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomeScreen()),
        );
        // Update last login time
        await userDoc.update({'lastLoginAt': DateTime.now()});
      }


    } catch (e) {
      print('Error in checkPhoneNumber: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    print('Signing out user: ${currentUser?.uid}'); // Debug log
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      
      // Clear local user data
      currentUserModel = null;
      currentUserId = null;
      
      print('Sign out successful'); // Debug log
    } catch (e) {
      print('Error during sign out: $e'); // Debug log
      throw Exception('Failed to sign out: $e');
    }
  }
}
