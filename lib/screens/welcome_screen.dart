import 'package:bliszifly/components/elevated_button_widget.dart';
import 'package:bliszifly/components/text_widget.dart';
import 'package:bliszifly/screens/account/login_screen.dart';
import 'package:bliszifly/screens/account/signup_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  static const id = '/welcome_screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 225,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TextWidget(
                    text: 'BLIS',
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                    style: ButtonStyle(
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(10.0))),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButtonWidget(
                    title: 'SIGN UP',
                    onPressed: () {
                      Navigator.pushNamed(context, SignupScreen.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
