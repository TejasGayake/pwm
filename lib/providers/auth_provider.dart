import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  AppUser? get currentUser => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isEngineer => _user?.role == 'engineer';
  bool get isInvestor => _user?.role == 'investor';
  String? get error => _error;

  Future<bool> tryAutoLogin() async {
    _isLoading = true; notifyListeners();
    _user = await _authService.tryAutoLogin();
    _isLoading = false; notifyListeners();
    return _user != null;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _user = await _authService.signIn(email, password);
      _isLoading = false; notifyListeners();
      return _user != null;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name, String phone, String role) async {
    return await register(name, email, phone, password, role);
  }

  Future<bool> register(String name, String email, String phone, String password, String role) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _user = await _authService.register(name, email, phone, password, role);
      _isLoading = false; notifyListeners();
      return _user != null;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null; notifyListeners();
  }
}
