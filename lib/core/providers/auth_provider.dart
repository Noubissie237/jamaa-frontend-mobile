import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; 
import '../constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String login, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final apiUrl = ApiConstants.login;
      debugPrint('[LOGIN] Tentative de connexion vers $apiUrl');
      debugPrint('[LOGIN] Body : {login: $login, password: $password}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': login, 'password': password}),
      );

      debugPrint('[LOGIN] Statut réponse : ${response.statusCode}');
      debugPrint('[LOGIN] Corps réponse : ${response.body}');

      if (response.statusCode == 200) {
        final token = response.body;
        debugPrint('[LOGIN] Token reçu : $token');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Décodage du payload JWT
        final parts = token.split('.');
        if (parts.length != 3) throw Exception('Token invalide');

        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        debugPrint('[LOGIN] Payload JWT décodé : $payload');

        final payloadMap = jsonDecode(payload);

        _currentUser = User(
          id: '', // Ajoute l'id si dispo
          firstName: payloadMap['firstName'] ?? '',
          lastName: payloadMap['lastName'] ?? '',
          email: payloadMap['email'] ?? '',
          phone: payloadMap['phone'] ?? '',
          cniNumber: '', // Si présent, ajoute le champ
          createdAt: DateTime.now(),
          isVerified: true,
        );

        debugPrint('[LOGIN] Utilisateur connecté : ${_currentUser?.email}');
        _isAuthenticated = true;
        notifyListeners();

      } else {
        String errorMessage = 'Identifiants invalides';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          debugPrint('[LOGIN] Erreur lors du décodage de l’erreur JSON : $e');
        }

        _error = errorMessage;
        _isAuthenticated = false;
        notifyListeners();
      }

    } catch (e, stack) {
      debugPrint('[LOGIN] Exception : $e');
      debugPrint('[LOGIN] Stacktrace : $stack');
      _error = 'Erreur de connexion';
      _isAuthenticated = false;
      notifyListeners();
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