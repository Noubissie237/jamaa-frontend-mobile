import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; 
import '../constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  /// Loads the current user from the JWT token stored in SharedPreferences.
  Future<void> loadCurrentUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    bool needsRelogin = false;
    Map<String, dynamic>? payloadMap;

    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length != 3) throw Exception('Token invalide');
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        payloadMap = jsonDecode(payload);
        // Vérification expiration (champ exp en secondes depuis epoch)
        if (payloadMap != null && payloadMap.containsKey('exp')) {
          final exp = payloadMap['exp'];
          final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          final now = DateTime.now();
          if (expiry.isBefore(now)) {
            needsRelogin = true;
          }
        }
      } catch (e) {
        needsRelogin = true;
      }
    } else {
      needsRelogin = true;
    }

    if (needsRelogin) {
      final email = prefs.getString('user_email');
      final password = prefs.getString('user_password');
      if (email != null && password != null) {
        await login(email, password);
        token = prefs.getString('auth_token');
        if (token != null) {
          try {
            final parts = token.split('.');
            if (parts.length != 3) throw Exception('Token invalide');
            final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
            payloadMap = jsonDecode(payload);
          } catch (e) {
            _currentUser = null;
            _isAuthenticated = false;
            notifyListeners();
            return;
          }
        } else {
          _currentUser = null;
          _isAuthenticated = false;
          notifyListeners();
          return;
        }
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
        return;
      }
    }

    // Si on arrive ici, payloadMap est valide
    _currentUser = User(
      id: '', // Ajoute l'id si dispo
      firstName: payloadMap != null && payloadMap['firstName'] != null ? payloadMap['firstName'] : '',
      lastName: payloadMap != null && payloadMap['lastName'] != null ? payloadMap['lastName'] : '',
      email: payloadMap != null && payloadMap['email'] != null ? payloadMap['email'] : '',
      phone: payloadMap != null && payloadMap['phone'] != null ? payloadMap['phone'] : '',
      cniNumber: '',
      createdAt: DateTime.now(),
      isVerified: true,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

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
        // Save token
        await prefs.setString('auth_token', token);
        // Save credentials for auto-login on PIN
        await prefs.setString('user_email', login);
        await prefs.setString('user_password', password);

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
  File? cniRectoFile,
  File? cniVersoFile,
}) async {
  _setLoading(true);
  _error = null;

  try {
    // 1. Upload des fichiers CNI
    Future<String?> uploadCniImage(File? file) async {
      if (file == null) return null;

      final uri = Uri.parse(ApiConstants.uploadCni);
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint('[UPLOAD] Réussi : ${response.body}');
        return response.body.replaceAll('"', ''); // nettoie les guillemets si JSON string
      } else {
        debugPrint('[UPLOAD] Échec : ${response.body}');
        return null;
      }
    }

    final cniRectoPath = await uploadCniImage(cniRectoFile);
    final cniVersoPath = await uploadCniImage(cniVersoFile);

    // 2. Mutation GraphQL
    const String endpoint = ApiConstants.register;

    final mutation = '''
      mutation {
        createCustomer(input: {
          firstName: "$firstName",
          lastName: "$lastName",
          email: "$email",
          password: "$password",
          phone: "$phone",
          cniNumber: "${cniNumber ?? ''}",
          cniRecto: "${cniRectoPath ?? ''}",
          cniVerso: "${cniVersoPath ?? ''}"
        }) {
          id
          firstName
          lastName
          email
          phone
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': mutation}),
    );

    debugPrint('[REGISTER] Statut : ${response.statusCode}');
    debugPrint('[REGISTER] Body : ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final user = data['data']?['createCustomer'];

      if (user != null) {
        _currentUser = User(
          id: user['id'] ?? '',
          firstName: user['firstName'] ?? '',
          lastName: user['lastName'] ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          cniNumber: cniNumber ?? '',
          cniRectoImage: cniRectoPath,
          cniVersoImage: cniVersoPath,
          createdAt: DateTime.now(),
          isVerified: false,
        );

        _isAuthenticated = true;
        notifyListeners();
      } else {
        _error = 'Erreur : utilisateur non créé.';
        _isAuthenticated = false;
        notifyListeners();
      }
    } else {
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _error = errorData['errors']?[0]?['message'] ?? 'Erreur inconnue';
      } catch (e) {
        _error = 'Erreur lors de l\'inscription';
      }

      _isAuthenticated = false;
      notifyListeners();
    }

  } catch (e, stack) {
    debugPrint('[REGISTER] Exception : $e');
    debugPrint('[REGISTER] Stacktrace : $stack');
    _error = 'Erreur d\'inscription';
    _isAuthenticated = false;
    notifyListeners();
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