import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth    _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Stream ─────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Sign In ────────────────────────────────────────
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    }
  }

  // ── Sign Up (creates Auth user + Firestore doc) ────
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);

      // Update display name
      await cred.user!.updateDisplayName(name.trim());

      // Create Firestore user document
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid':       cred.user!.uid,
        'name':      name.trim(),
        'email':     email.trim(),
        'phone':     phone.trim(),
        'role':      'user',   // default — manually set admin in Firestore console
        'profileImageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive':  true,
      });

      // Send email verification
      await cred.user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    }
  }

  // ── Password Reset ─────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    }
  }

  // ── Change Password ────────────────────────────────
  Future<void> changePassword(String current, String newPass) async {
    try {
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!, password: current);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    }
  }

  // ── Get User Model ─────────────────────────────────
  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ── Sign Out ───────────────────────────────────────
  Future<void> signOut() async => await _auth.signOut();

  // ── Admin: trigger reset for any user ─────────────
  Future<void> adminResetUserPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Friendly error messages ────────────────────────
  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':     return 'No account found with this email.';
      case 'wrong-password':     return 'Incorrect password. Try again.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password':      return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':      return 'Invalid email address.';
      case 'too-many-requests':  return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Check your connection.';
      default:                   return 'Authentication error. Please try again.';
    }
  }
}
