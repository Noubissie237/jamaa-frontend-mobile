import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';
import '../models/bank.dart';

class BankProvider extends ChangeNotifier {
  List<Bank> _banks = [];
  bool _isLoading = false;
  String? _error;

  List<Bank> get banks => _banks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBanks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiConstants.bankServiceUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': '''
            query GetAllBanks {
              banks {
                id
                name
                slogan
                logoUrl
                minimumBalance
                withdrawFees
                internalTransferFees
                externalTransferFees
                createdAt
                updatedAt
              }
            }
          '''
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List banksJson = data['data']['banks'];
        _banks = banksJson.map((json) => Bank.fromJson(json)).toList();
      } else {
        _error = 'Erreur réseau : ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
