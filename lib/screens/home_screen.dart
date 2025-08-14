import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parval/screens/login_screen.dart';
import '../services/plaid_service.dart';

const String plaidClientId = '689d6938fc0460002328deaa';
const String plaidSecret = '08349bbe8ac7a35f464932ccf56c2d';
const String plaidSandboxUrl = 'https://sandbox.plaid.com';
const String appName = 'Parval';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaidService _plaidService = PlaidService();

  bool _isLoading = false;

  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    String? token = await _plaidService.getAccessToken();

    var data = await _plaidService.getAccountBalance(token ?? '');

    setState(() => _isLoading = false);

    setState(() {
      _data = data;
    });
  }

  void _showAccountDetails(dynamic account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account['name'] ?? 'Cuenta Desconocida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${account['type']} / ${account['subtype']}'),
            Text('Número  de Cuenta: ${account['mask']}'),
            Text(
              'Balance Disponible: \$${account['balances']['available'] ?? 'N/A'}',
            ),
            Text(
              'Balance Actual: \$${account['balances']['current'] ?? 'N/A'}',
            ),
            Text('Limite: \$${account['balances']['limit'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogOut() async {
    await _plaidService.deleteAccessToken();

    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  List<String> _getTypes() {
    List<String> types = [];

    _data.forEach((e) {
      if (!types.contains(e['type'])) {
        types.add(e['type']);
      }
    });

    return types;
  }

  List<dynamic> _getAccountsByType(String type) {
    List<dynamic> accounts = [];

    _data.forEach((e) {
      if (e['type'] == type) {
        accounts.add(e);
      }
    });

    return accounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Image.asset('assets/images/logo.png'),
        title: Text('Bienvenido', style: TextStyle(color: Colors.grey)),
        actions: [
          IconButton(
            onPressed: () => _handleLogOut(),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 30),
            if (_isLoading) CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: _getTypes().length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text('Tipo: ${_getTypes()[index]}'),
                    children: _getAccountsByType(_getTypes()[index])
                        .map(
                          (account) => ListTile(
                            title: Text('Nonbre: ${account['name']}'),
                            subtitle: Text(
                              'Disponible: \$${account['balances']['available'] ?? 'N/A'}',
                            ),
                            onTap: () => _showAccountDetails(account),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
