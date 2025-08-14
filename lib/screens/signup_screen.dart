import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:parval/screens/home_screen.dart';
import 'package:parval/services/plaid_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController(
    text: '',
  );

  final TextEditingController _cedulaController = TextEditingController(
    text: '',
  );
  final TextEditingController _dateController = TextEditingController(text: '');
  DateTime? _selectedDate;
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );
  final TextEditingController _userNameController = TextEditingController(
    text: '',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '',
  );

  String? _fullNameError;
  String? _cedulaError;
  String? _dateError;
  String? _emailError;
  String? _userNameError;
  String? _passwordError;

  bool _loading = false;

  bool _showPassword = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _cedulaController.dispose();
    _dateController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  bool _isValidFullName() {
    String value = _fullNameController.text;
    String? error;

    if (value.length < 2) {
      error = 'Muy Corto';
    }
    if (value.isEmpty) {
      error = 'Campo vacio';
    }

    setState(() => _fullNameError = error);
    return error == null;
  }

  bool _isValidCedula() {
    String value = _cedulaController.text;
    String? error;

    if (value.length != 13) {
      error = 'Inserte cedula valida';
    }

    setState(() => _cedulaError = error);
    return error == null;
  }

  bool _isValidDate() {
    DateTime? value = _selectedDate;
    String? error;

    if (value == null) {
      error = 'Seleccione una Fecha';
    }

    setState(() => _dateError = error);
    return error == null;
  }

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool _isValidEmail() {
    String value = _emailController.text;
    String? error;

    if (!_emailRegExp.hasMatch(value)) {
      error = 'Correo Invalido';
    }

    if (value.isEmpty) {
      error = 'Campo vacio';
    }

    setState(() => _emailError = error);
    return error == null;
  }

  bool _isValidUserName() {
    String value = _userNameController.text;
    String? error;

    if (value.length < 4) {
      error = 'Muy Corto';
    }
    if (value.isEmpty) {
      error = 'Campo vacio';
    }

    setState(() => _userNameError = error);
    return error == null;
  }

  final List<String> _commonPasswords = [
    'password',
    '12345678',
    'qwerty',
    'abc123',
    'letmein',
  ];
  bool _isValidPassword() {
    String value = _passwordController.text;
    String? error;

    if (_commonPasswords.contains(value.toLowerCase())) {
      error = 'Contraseña muy comun';
    }

    if (value.length > 64) {
      error = 'Contraseña muy larga';
    }
    if (value.length < 8) {
      error = 'Contraseña muy corta';
    }
    if (value.isEmpty) {
      error = 'Campo vacio';
    }

    setState(() => _passwordError = error);
    return error == null;
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_isValidFullName() &&
        _isValidCedula() &&
        _isValidDate() &&
        _isValidEmail() &&
        _isValidUserName() &&
        _isValidPassword()) {
      PlaidService plaidService = PlaidService();

      String fullName = _fullNameController.text;
      String cedula = _cedulaController.text;
      String date = _dateController.text;
      String email = _emailController.text;
      String userName = _userNameController.text;
      String password = _passwordController.text;

      setState(() => _loading = true);

      String? token = await plaidService.signUp(userName, password);

      setState(() => _loading = false);

      if (token != null && mounted) {
        await plaidService.saveAccessToken(token);
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Información Incorrecta',
              style: TextStyle(fontSize: 18),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  final _cedulaMaskFormatter = MaskTextInputFormatter(
    mask: '###-#######-#',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20),
        child: Column(
          children: [
            SizedBox(height: 50),
            Center(
              child: Image.asset('assets/images/login_image.png', width: 120),
            ),
            SizedBox(height: 15),
            Text(
              'Crea una cuenta de Parval',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            Divider(),
            SizedBox(height: 20),
            TextField(
              controller: _fullNameController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                helperText: _fullNameError,
                helperStyle: TextStyle(color: Colors.red, fontSize: 14),
                prefixIcon: Icon(Icons.person, color: Colors.grey),
                labelText: 'Nombre Completo',
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
              style: TextStyle(fontSize: 20),
              controller: _cedulaController,
              inputFormatters: [_cedulaMaskFormatter],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.badge, color: Colors.grey),
                labelText: 'Cédula (405-2583441-1)',
                helperText: _cedulaError,
                helperStyle: TextStyle(color: Colors.red, fontSize: 14),
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
              style: TextStyle(fontSize: 20),
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                labelText: 'Fecha de nacimiento',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                helperText: _dateError,
                helperStyle: TextStyle(color: Colors.red, fontSize: 14),
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
              style: TextStyle(fontSize: 20),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: Colors.grey),
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                helperText: _emailError,
                helperStyle: TextStyle(color: Colors.red, fontSize: 14),
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
              controller: _userNameController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.grey),
                labelText: 'Usuario',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                helperText: _userNameError,
                helperStyle: TextStyle(color: Colors.red, fontSize: 14),
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
              style: TextStyle(fontSize: 20),
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                helperText: _passwordError,
                helperStyle: TextStyle(color: Colors.red, fontSize: 14),
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
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _handleSubmit(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff4b90f),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Registrarme',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffbcbdc1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text(
                  'Hacia atrás',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






/*

     // Validate the password
                String? errorMessage = _validatePassword(_passwordController.text);
                if (errorMessage == null) {
                  // Navigate to success screen, removing the current route
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SuccessScreen()),
                  );
                } else {
                  // Show error message in a SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }

 */