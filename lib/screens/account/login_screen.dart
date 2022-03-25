import 'package:bliszifly/components/elevated_button_widget.dart';
import 'package:bliszifly/components/text_widget.dart';
import 'package:bliszifly/components/textfield_widget.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/screens/admin/admin_login_screen.dart';
import 'package:bliszifly/screens/home_screen.dart';
import 'package:bliszifly/validations/login_validation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const id = '/login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  LoginValidation validation = LoginValidation();
  String? userName;
  String? password;
  String? passwordHint;


  void _navigate() => Navigator.pushNamed(context, HomeScreen.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldkey,
          appBar: AppBar(
            title: const Text('LOGIN'),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: SizedBox(
                  width: 225,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TextWidget(text: 'BLIS'),
                      BlisTextFormField(
                        text: 'Username',
                        validator: (String? value) {
                          userName = value;
                          return validation.unameValidation(value);
                        },
                      ),
                      BlisTextFormField(
                        text: 'Password',
                        obscureText: true,
                        validator: (String? value) {
                          password = value;
                          return validation.passwordValidation(value);
                        },
                      ),
                      ElevatedButtonWidget(
                        title: 'LOG IN',
                        onPressed: () async {
                          bool? error;
                          var formValidated =
                              _formKey.currentState!.validate();
                          if (formValidated) {
                            error = await DbManager.fetchLoginCreds(userName!, 0, 'BLIS_USER');
                            if (error == true) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Username.'),));
                              error = false;
                            } else if (error == false) {
                              error = await DbManager.fetchLoginCreds(password!, 1, 'BLIS_USER');
                              if (error == false) {
                                DbManager.userName = userName;
                                _navigate();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful.'),));
                                formValidated = false;
                              } else {
                                fetchPasswordHint();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid password.'),));
                                error = false;
                              }
                            }
                          }
                        },
                      ),
                      Text('${passwordHint ?? ''} ')
                    ],
                  ),
                ),
              ),
            ),
          ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_moderator),
          tooltip: 'Admin Login',
          onPressed: () => Navigator.pushNamed(context, AdminLoginScreen.id),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void fetchPasswordHint() async {
    List<List<dynamic>> username = await DbManager.connection!.query(
        "SELECT PASSWORD_HINT FROM BLIS_USER WHERE USERNAME = @USERNAME",
    substitutionValues: {
          "USERNAME": userName
    });
    setState(() {
      passwordHint = "Password Hint : " + username[0][0];
    });
  }
}
