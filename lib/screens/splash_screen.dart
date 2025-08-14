import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:parval/screens/home_screen.dart';
import 'package:parval/screens/login_screen.dart';
import 'package:parval/services/plaid_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 220),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 350,
              width: 350,
            ),
          ),
          SizedBox(
            width: 350.0,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 26.0,
                fontFamily: 'Agne',
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              child: AnimatedTextKit(
                repeatForever: false,
                totalRepeatCount: 2,
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Parval construye tu sueño',
                    textAlign: TextAlign.center,
                    speed: Duration(milliseconds: 80),
                  ),
                ],
                onFinished: () async {
                  PlaidService plaidService = PlaidService();

                  String? token = await plaidService.getAccessToken();

                  if (token != null && mounted) {
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return HomeScreen();
                        },
                      ),
                    );
                    return;
                  }

                  if (token == null && mounted) {
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
