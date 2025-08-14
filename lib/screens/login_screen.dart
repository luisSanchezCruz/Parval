import 'package:flutter/material.dart';
import 'package:parval/screens/home_screen.dart';
import 'package:parval/screens/signup_screen.dart';
import 'package:parval/services/plaid_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController(
    text: '',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '',
  );
  bool _passwordVisible = false;

  bool _loading = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset('assets/images/login_image.png', width: 200),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _userNameController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.grey),
                labelText: 'Nombre de usuario',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              style: TextStyle(fontSize: 20),
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String username = _userNameController.text;
                  String password = _passwordController.text;
                  PlaidService plaidService = PlaidService();

                  if (username.isNotEmpty && password.isNotEmpty) {
                    setState(() => _loading = true);

                    String? token = await plaidService.logIn(
                      username,
                      password,
                    );

                    setState(() => _loading = false);

                    if (token != null && mounted) {
                      await plaidService.saveAccessToken(token);
                      await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        (Route<dynamic> route) => false,
                      );
                      return;
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Credenciales Invalidos!',
                        style: TextStyle(fontSize: 18),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff3b90e),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Ingresar',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SignupScreen();
                      },
                    ),
                  );
                },
                child: Text(
                  'Registrarme',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff6c757d),
                  // primary: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
