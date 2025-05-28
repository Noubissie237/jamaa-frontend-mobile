import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      // Simulation d'appel API
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock user data
      _currentUser = User(
        id: '1',
        firstName: 'Noubissie',
        lastName: 'Wilfried',
        email: email,
        phone: '+237690232120',
        cniNumber: '123456789',
        createdAt: DateTime.now(),
        isVerified: true,
      );
      
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de connexion';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? cniNumber,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        cniNumber: cniNumber,
        createdAt: DateTime.now(),
        isVerified: false,
      );
      
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur d\'inscription';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOTP(String otp) async {
    _setLoading(true);
    _error = null;

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          firstName: _currentUser!.firstName,
          lastName: _currentUser!.lastName,
          email: _currentUser!.email,
          phone: _currentUser!.phone,
          cniNumber: _currentUser!.cniNumber,
          profilePicture: _currentUser!.profilePicture,
          createdAt: _currentUser!.createdAt,
          isVerified: true,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Code OTP invalide';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}