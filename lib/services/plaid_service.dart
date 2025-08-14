import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String plaidClientId = '689d6938fc0460002328deaa';
const String plaidSecret = '08349bbe8ac7a35f464932ccf56c2d';
const String plaidSandboxUrl = 'https://sandbox.plaid.com';

class PlaidService {
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    return token;
  }

  Future<void> deleteAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }

  Future<String?> createPublicToken(String username, String password) async {
    const url = 'https://sandbox.plaid.com/sandbox/public_token/create';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': plaidClientId,
        'secret': plaidSecret,
        'institution_id': 'ins_109508',
        'initial_products': ['assets', 'auth', 'identity'],
        'options': {
          'override_username': username,
          'override_password': password,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['public_token'];
    } else {
      return null;
    }
  }

  Future<String?> exchangePublicToken(String publicToken) async {
    const url = 'https://sandbox.plaid.com/item/public_token/exchange';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': plaidClientId,
        'secret': plaidSecret,
        'public_token': publicToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      return null;
    }
  }

  Future<List<dynamic>> getAccountBalance(String accessToken) async {
    const url = 'https://sandbox.plaid.com/accounts/balance/get';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': plaidClientId,
        'secret': plaidSecret,
        'access_token': accessToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['accounts'];
    } else {
      return [];
    }
  }

  Future<String?> signUp(String username, String password) async {
    try {
      final publicToken = await createPublicToken(username, password);

      if (publicToken == null) {
        return null;
      }

      final accessToken = await exchangePublicToken(publicToken);

      return accessToken;
    } catch (e) {
      return null;
    }
  }

  Future<String?> logIn(String username, String password) async {
    try {
      final publicToken = await createPublicToken(username, password);

      if (publicToken == null) {
        return null;
      }
      final accessToken = await exchangePublicToken(publicToken);

      return accessToken;
    } catch (e) {
      return null;
    }
  }
}
