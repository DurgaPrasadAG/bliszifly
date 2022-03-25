import 'package:bliszifly/components/elevated_button_widget.dart';
import 'package:bliszifly/components/text_widget.dart';
import 'package:bliszifly/components/textfield_widget.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/screens/account/login_screen.dart';
import 'package:bliszifly/validations/signup_validation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class SignupScreen extends StatefulWidget {
  static const id = '/signup_screen';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String? userName, name, password, confirmPassword, passwordHint;

  Future<bool?> addUser() async {
    bool? success;

    try {
      await DbManager.connection!.execute(
          """
        INSERT INTO BLIS_USER
        VALUES (@USERNAME, @NAME, @PASSWORD, @PASSWORD_HINT)
        """, substitutionValues: {
        "USERNAME": userName,
        "NAME": name,
        "PASSWORD": password,
        "PASSWORD_HINT": passwordHint
      });
      success = true;
    } on PostgreSQLException {
      success = false;
      _showSnackbar("Username already exists.");
    }

    return success;
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigate() => Navigator.pushNamed(context, LoginScreen.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('SIGN UP'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: SizedBox(
                  width: 225,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TextWidget(text: 'BLIS'),
                      BlisTextFormField(
                        text: 'Username',
                        validator: (String? value) {
                          userName = value;
                          return SignUpValidation.userNameValidation(value);
                        },
                      ),
                      BlisTextFormField(
                        text: 'Name',
                        validator: (String? value) {
                          name = value;
                          return SignUpValidation.nameValidation(value);
                        },
                      ),
                      BlisTextFormField(
                        obscureText: true,
                        text: 'Password',
                        validator: (String? value) {
                          password = value;
                          return SignUpValidation.passwordValidation(value);
                        },
                      ),
                      BlisTextFormField(
                        obscureText: true,
                        text: 'Confirm password',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm password";
                          } else if (value != password) {
                            return "Password didn't match";
                          }
                          confirmPassword = value;
                          return null;
                        },
                      ),
                      BlisTextFormField(
                        text: 'Password Hint',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please provide password hint";
                          }
                          passwordHint = value;
                          return null;
                        },
                      ),
                      ElevatedButtonWidget(
                        title: 'SIGN UP',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool? success = await addUser();
                            if (success!) {
                              _navigate();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
    );
  }
}
