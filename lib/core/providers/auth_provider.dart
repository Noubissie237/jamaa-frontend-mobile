import 'dart:core';

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
      id: payloadMap != null && payloadMap['id'] != null ? payloadMap['id'] : '',
      firstName: payloadMap != null && payloadMap['firstName'] != null ? payloadMap['firstName'] : '',
      lastName: payloadMap != null && payloadMap['lastName'] != null ? payloadMap['lastName'] : '',
      email: payloadMap != null && payloadMap['email'] != null ? payloadMap['email'] : '',
      phone: payloadMap != null && payloadMap['phone'] != null ? payloadMap['phone'] : '',
      cniNumber: '',
      createdAt: DateTime.now(),
      isVerified: payloadMap != null && payloadMap['isVerified'] != null ? payloadMap['isVerified'] : false,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    _setLoading(true);
    _error = null;

    try {
      final query = '''
      query {
        getCustomerById(id: "${_currentUser?.id}") {
          id
          firstName
          lastName
          email
          phone
          isVerified
          cniNumber
        }
      }
      ''';
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      if (data['data'] != null) {
        _currentUser!.isVerified = data['data']['getCustomerById']['isVerified'];
        _currentUser!.cniNumber = data['data']['getCustomerById']['cniNumber'];
        _currentUser!.firstName = data['data']['getCustomerById']['firstName'];
        _currentUser!.lastName = data['data']['getCustomerById']['lastName'];
        _currentUser!.email = data['data']['getCustomerById']['email'];
        _currentUser!.phone = data['data']['getCustomerById']['phone'];
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }


  User? _currentUser;
  User? _tmpUser;
  int? _tmpUserId;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  int? get tmpUserId => _tmpUserId;
  User? get currentUser => _currentUser;
  User? get tmpUser => _tmpUser;
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
          id: payloadMap['id'] ?? '', 
          firstName: payloadMap['firstName'] ?? '',
          lastName: payloadMap['lastName'] ?? '',
          email: payloadMap['email'] ?? '',
          phone: payloadMap['phone'] ?? '',
          cniNumber: '', // Si présent, ajoute le champ
          createdAt: DateTime.now(),
          isVerified: payloadMap['isVerified'] ?? false,
        );

        refreshUserData(); // Pour récupérer le status (isVerified)

        debugPrint('[LOGIN] Utilisateur connecté : ${_currentUser?.email}');
        _isAuthenticated = true;
        notifyListeners();

      } else {
        String errorMessage = 'Email ou mot de passe incorrect';
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
  debugPrint('🚀 [REGISTER] Début de l\'inscription...');
  debugPrint('📋 [REGISTER] Données utilisateur:');
  debugPrint('   👤 Nom: $lastName $firstName');
  debugPrint('   📧 Email: $email');
  debugPrint('   📱 Téléphone: $phone');
  debugPrint('   🆔 CNI: ${cniNumber ?? 'Non fourni'}');
  debugPrint('   📄 Fichier recto: ${cniRectoFile?.path ?? 'Aucun'}');
  debugPrint('   📄 Fichier verso: ${cniVersoFile?.path ?? 'Aucun'}');

  _setLoading(true);
  _error = null;

  try {
    // 1. Upload des fichiers CNI
    Future<String?> uploadCniImage(File? file, String type) async {
      if (file == null) {
        debugPrint('⏭️  [UPLOAD-$type] Aucun fichier à uploader');
        return null;
      }

      debugPrint('📤 [UPLOAD-$type] Début de l\'upload...');
      debugPrint('   📁 Chemin: ${file.path}');
      
      try {
        // Vérifier que le fichier existe
        if (!await file.exists()) {
          debugPrint('❌ [UPLOAD-$type] Le fichier n\'existe pas!');
          return null;
        }

        final fileSize = await file.length();
        debugPrint('   📏 Taille: ${fileSize} bytes (${(fileSize / 1024).toStringAsFixed(1)} KB)');

        final uri = Uri.parse(ApiConstants.uploadCni);
        debugPrint('   🌐 URL: $uri');

        final request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        
        debugPrint('   ⏱️  Envoi de la requête...');
        final stopwatch = Stopwatch()..start();
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        stopwatch.stop();
        debugPrint('   ⏱️  Temps de réponse: ${stopwatch.elapsedMilliseconds}ms');
        debugPrint('   📡 Status: ${response.statusCode}');
        debugPrint('   📝 Headers: ${response.headers}');

        if (response.statusCode == 200) {
          final cleanResponse = response.body.replaceAll('"', '');
          debugPrint('✅ [UPLOAD-$type] Réussi!');
          debugPrint('   🔗 URL/Path retournée: $cleanResponse');
          return cleanResponse;
        } else {
          debugPrint('❌ [UPLOAD-$type] Échec!');
          debugPrint('   📝 Réponse: ${response.body}');
          debugPrint('   📋 Raison: ${response.reasonPhrase}');
          return null;
        }
      } catch (e, stack) {
        debugPrint('💥 [UPLOAD-$type] Exception: $e');
        debugPrint('   📊 Stack: $stack');
        return null;
      }
    }

    // Upload séquentiel des fichiers
    debugPrint('📸 [UPLOADS] Phase d\'upload des fichiers CNI...');
    
    final cniRectoPath = await uploadCniImage(cniRectoFile, 'RECTO');
    final cniVersoPath = await uploadCniImage(cniVersoFile, 'VERSO');

    debugPrint('📊 [UPLOADS] Résumé des uploads:');
    debugPrint('   📄 Recto: ${cniRectoPath ?? 'ÉCHEC'}');
    debugPrint('   📄 Verso: ${cniVersoPath ?? 'ÉCHEC'}');

    // 2. Mutation GraphQL
    debugPrint('🔄 [GRAPHQL] Préparation de la mutation...');
    
    const String endpoint = ApiConstants.register;
    debugPrint('   🌐 Endpoint: $endpoint');

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
          isVerified
          cniNumber
          cniRecto
          cniVerso
        }
      }
    ''';

    debugPrint('   📝 Mutation construite (${mutation.length} caractères)');
    
    final payload = jsonEncode({'query': mutation});
    debugPrint('   📦 Payload: ${payload.length} bytes');

    debugPrint('📡 [GRAPHQL] Envoi de la requête...');
    final graphqlStopwatch = Stopwatch()..start();

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    graphqlStopwatch.stop();
    debugPrint('⏱️  [GRAPHQL] Temps de réponse: ${graphqlStopwatch.elapsedMilliseconds}ms');
    debugPrint('📡 [GRAPHQL] Status: ${response.statusCode}');
    debugPrint('📝 [GRAPHQL] Headers: ${response.headers}');
    debugPrint('📄 [GRAPHQL] Body length: ${response.body.length} caractères');

    if (response.statusCode == 200) {
      debugPrint('✅ [GRAPHQL] Réponse HTTP 200 reçue');
      
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('📊 [GRAPHQL] JSON parsé avec succès');
        debugPrint('   🔍 Structure: ${data.keys.toList()}');
        
        final user = data['data']?['createCustomer'];
        debugPrint("données récupérés : $user");
        if (user != null) {
          debugPrint('👤 [USER] Utilisateur créé avec succès!');
          debugPrint('   🆔 ID: ${user['id']}');
          debugPrint('   👤 Nom: ${user['firstName']} ${user['lastName']}');
          debugPrint('   📧 Email: ${user['email']}');
          debugPrint('   📱 Téléphone: ${user['phone']}');
          debugPrint('   🆔 CNI: ${user['cniNumber']}');
          debugPrint('   📄 Recto: ${user['cniRecto']}');
          debugPrint('   📄 Verso: ${user['cniVerso']}');

          debugPrint(' Debut création du current user');
          _currentUser = User(
            id: int.parse(user['id']),
            firstName: user['firstName'] ?? '',
            lastName: user['lastName'] ?? '',
            email: user['email'] ?? '',
            phone: user['phone'] ?? '',
            cniNumber: user['cniNumber'] ?? '',
            cniRectoImage: user['cniRecto'] ?? '',
            cniVersoImage: user['cniVerso'] ?? '',
            createdAt: DateTime.now(),
            isVerified: user['isVerified'] ?? false,
          );
          debugPrint('Fin création du current user');

          _isAuthenticated = true;
          debugPrint('✅ [AUTH] Utilisateur authentifié localement');
          notifyListeners();
        } else {
          debugPrint('❌ [USER] Données utilisateur manquantes dans la réponse');
          debugPrint('   📊 Data reçue: $data');
          
          // Vérifier s'il y a des erreurs GraphQL
          if (data['errors'] != null) {
            debugPrint('⚠️  [GRAPHQL] Erreurs détectées: ${data['errors']}');
          }
          
          _error = 'Erreur : utilisateur non créé.';
          _isAuthenticated = false;
          notifyListeners();
        }
      } catch (jsonError, jsonStack) {
        debugPrint('💥 [JSON] Erreur de parsing: $jsonError');
        debugPrint('   📊 Stack: $jsonStack');
        debugPrint('   📄 Raw response: ${response.body}');
        _error = 'Erreur de format de réponse';
        _isAuthenticated = false;
        notifyListeners();
      }
    } else {
      debugPrint('❌ [GRAPHQL] Erreur HTTP ${response.statusCode}');
      debugPrint('   📝 Reason: ${response.reasonPhrase}');
      debugPrint('   📄 Body: ${response.body}');
      
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorMessage = errorData['errors']?[0]?['message'] ?? 'Erreur inconnue';
        debugPrint('   💬 Message d\'erreur: $errorMessage');
        _error = errorMessage;
      } catch (e) {
        debugPrint('   💥 Impossible de parser l\'erreur: $e');
        _error = 'Erreur lors de l\'inscription (HTTP ${response.statusCode})';
      }

      _isAuthenticated = false;
      notifyListeners();
    }

  } catch (e, stack) {
    debugPrint('💥 [REGISTER] Exception globale: $e');
    debugPrint('📊 [REGISTER] Stack trace complet:');
    debugPrint(stack.toString());
    _error = 'Erreur d\'inscription: ${e.toString()}';
    _isAuthenticated = false;
    notifyListeners();
  } finally {
    debugPrint('🏁 [REGISTER] Fin du processus d\'inscription');
    debugPrint('   ✅ Succès: $_isAuthenticated');
    debugPrint('   ❌ Erreur: ${_error ?? 'Aucune'}');
    _setLoading(false);
  }
}

Future<bool> emailExist(String email) async {
  _setLoading(true);
  final mutation = '''
    query {
      getCustomerByEmail(email: "$email") {
        id
        email
      }
    }
  ''';

  final response = await http.post(
    Uri.parse(ApiConstants.register),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': mutation}),
  );

  final data = jsonDecode(response.body);

  if (data['errors'] != null) {
    throw Exception(data['errors'][0]['message']);
  }

  if (response.statusCode == 200) {
    _setLoading(false);
    if(data['data']['getCustomerByEmail'] != null) {
      return true;
    }
    return false;
  }

  _setLoading(false);
  return false;
}

Future<User?> getUserById(String id) async {
  _setLoading(true);
  
  try {
    final query = '''
      query {
        getCustomerById(id: "$id") {
          id
          firstName
          lastName
          email
          phone
          cniNumber
          isVerified
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    final data = jsonDecode(response.body);

    if (data['errors'] != null) {
      throw Exception(data['errors'][0]['message']);
    }

    if (response.statusCode == 200) {
      if(data['data']['getCustomerById'] != null) {
        _tmpUser = User(
          id: int.parse(data['data']['getCustomerById']['id']),
          firstName: data['data']['getCustomerById']['firstName'],
          lastName: data['data']['getCustomerById']['lastName'],
          email: data['data']['getCustomerById']['email'],
          phone: data['data']['getCustomerById']['phone'],
          cniNumber: data['data']['getCustomerById']['cniNumber'],
          createdAt: DateTime.now(),
          isVerified: data['data']['getCustomerById']['isVerified'],
        );
        notifyListeners(); // Notifier les changements
        return _tmpUser;
      }
    }
    return null;
  } catch (e) {
    debugPrint('Erreur getUserById: $e');
    return null;
  } finally {
    _setLoading(false);
  }
}

Future<void> getUserByEmail(String email) async {
  _setLoading(true);
  final mutation = '''
    query {
      getCustomerByEmail(email: "$email") {
        id
      }
    }
  ''';

  final response = await http.post(
    Uri.parse(ApiConstants.register),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': mutation}),
  );

  final data = jsonDecode(response.body);

  if (data['errors'] != null) {
    throw Exception(data['errors'][0]['message']);
  }

  if (response.statusCode == 200) {
    _setLoading(false);
    if(data['data']['getCustomerByEmail'] != null) {
      _tmpUserId = int.parse(data['data']['getCustomerByEmail']['id']);
    }
  }
  _setLoading(false);
}

Future<void> updatePassword(int id, String password) async {
  _setLoading(true);
  final mutation = '''
    mutation {
      updateCustomerPassword(id: "$id", password: "$password") {
        id
        password
      }
    }
  ''';

  final response = await http.post(
    Uri.parse(ApiConstants.register),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': mutation}),
  );

  final data = jsonDecode(response.body);

  if (data['errors'] != null) {
    throw Exception(data['errors'][0]['message']);
  }

  if (response.statusCode == 200) {
    refreshUserData();
    _setLoading(false);
  }
}

Future<void> updateProfile(String email, String phone, String cniNumber, String firstName, String lastName) async {
  _setLoading(true);

  final mutation = '''
    mutation {
      updateCustomer(id: "${_currentUser?.id}", email: "$email", phone: "$phone", cniNumber: "$cniNumber", firstName: "$firstName", lastName: "$lastName") {
        id
        email
        phone
        cniNumber
        firstName
        lastName
      }
    }
  ''';

  final response = await http.post(
    Uri.parse(ApiConstants.register),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': mutation}),
  );

  final data = jsonDecode(response.body);

  if (data['errors'] != null) {
    throw Exception(data['errors'][0]['message']);
  }

  if (response.statusCode == 200) {
    refreshUserData();
    _setLoading(false);
  }

}

Future<void> logout() async {
  debugPrint('🚪 [LOGOUT] Début de la déconnexion...');
  debugPrint('   👤 Utilisateur actuel: ${_currentUser?.email ?? 'Aucun'}');
  
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // ⚠️ IMPORTANT: Supprimer TOUTES les données sensibles
    debugPrint('🧹 [LOGOUT] Suppression des données stockées...');
    
    // Supprimer le token JWT
    await prefs.remove('auth_token');
    debugPrint('   🗑️ Token JWT supprimé');
    
    // Supprimer les credentials (email/password)
    await prefs.remove('user_email');
    await prefs.remove('user_password');
    debugPrint('   🗑️ Credentials supprimés');
    
    // Supprimer autres données utilisateur
    await prefs.remove('user_data');
    debugPrint('   🗑️ Données utilisateur supprimées');

    // Réinitialisation de l'état
    final wasAuthenticated = _isAuthenticated;
    
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    
    debugPrint('   ✅ État réinitialisé');
    debugPrint('   📊 Était connecté: $wasAuthenticated');
    
    notifyListeners();
    debugPrint('   🔔 Listeners notifiés');
    
    debugPrint('✅ [LOGOUT] Déconnexion terminée avec succès');
    
  } catch (e, stack) {
    debugPrint('💥 [LOGOUT] Erreur: $e');
    debugPrint('📊 [LOGOUT] Stack: $stack');
    
    // Force la déconnexion même en cas d'erreur
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
    
    debugPrint('⚠️ [LOGOUT] Déconnexion forcée malgré l\'erreur');
  }
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