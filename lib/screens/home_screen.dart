import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parval/screens/login_screen.dart';
import 'package:parval/services/currerncy_service.dart';
import '../services/plaid_service.dart';
import 'package:intl/intl.dart';

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
  num? _DOP;

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());
    unawaited(_loadDOP());
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

  Future<void> _loadDOP() async {
    CurrencyService currencyService = CurrencyService();
    var result = await currencyService.getUSDToDOP();
    setState(() {
      _DOP = result;
    });
  }

  String _formatValue(num? value) {
    String symbol = _DOP == null ? 'US' : 'RD';

    num exchagevalue = _DOP ?? 1;

    num newValue = value == null ? 0 : exchagevalue * value;

    final formatCurrency = NumberFormat.simpleCurrency();

    String result = formatCurrency.format(newValue);

    return '$symbol$result';
  }

  String _accountTypeText(String value) {
    Map<String, String> map = {
      'depository': 'Depósito',
      'credit': 'Crédito',
      'investment': 'Inversiones',
      'loan': 'Préstamo',
    };

    return map[value] ?? value;
  }

  Widget _accountTypeIcon(String value) {
    Map<String, Widget> map = {
      'depository': Icon(
        Icons.account_balance_wallet,
        color: const Color(0xfff3b90e),
      ),
      'credit': Icon(Icons.credit_card, color: const Color(0xfff3b90e)),
      'investment': Icon(
        Icons.candlestick_chart,
        color: const Color(0xfff3b90e),
      ),
      'loan': Icon(Icons.payment, color: const Color(0xfff3b90e)),
    };

    return map[value] ?? Icon(Icons.credit_card);
  }

  void _showAccountDetails(dynamic account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,

        title: Text(account['name'] ?? 'Cuenta Desconocida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            SizedBox(height: 10),
            Text(
              'Tipo: ${_accountTypeText(account['type'])}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Número de cuenta: ${account['mask']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Balance disponible: ${_formatValue(account['balances']['available'])}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Balance actual: ${_formatValue(account['balances']['current'])}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Limite: ${_formatValue(account['balances']['limit'])}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Divider(),
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
                    leading: _accountTypeIcon(_getTypes()[index]),
                    title: Text(
                      _accountTypeText(_getTypes()[index]),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: _getAccountsByType(_getTypes()[index])
                        .map(
                          (account) => ListTile(
                            title: Text(
                              'Nombre: ${account['name']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Disponible: ${_formatValue(account['balances']['available'])}',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
