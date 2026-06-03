import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User?      _firebaseUser;
  UserModel? _userModel;
  bool       _loading = false;
  String?    _error;

  User?      get firebaseUser => _firebaseUser;
  UserModel? get userModel    => _userModel;
  bool       get loading      => _loading;
  String?    get error        => _error;
  bool       get isLoggedIn   => _firebaseUser != null;
  bool       get isAdmin      => _userModel?.isAdmin ?? false;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _userModel = await _authService.getUserModel(user.uid);
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email, password);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    try {
      await _authService.signUp(
        name: name, email: email, password: password, phone: phone);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void refreshUser() async {
    if (_firebaseUser != null) {
      _userModel = await _authService.getUserModel(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String e) { _error = e; notifyListeners(); }
  void _clearError()       { _error = null; }
  void clearError()        { _clearError(); notifyListeners(); }
}
