import 'package:bliszifly/components/elevated_button_widget.dart';
import 'package:bliszifly/components/text_widget.dart';
import 'package:bliszifly/components/textfield_widget.dart';
import 'package:bliszifly/screens/admin/report_screen.dart';
import 'package:bliszifly/validations/login_validation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:bliszifly/models/db_manager.dart';

class AdminLoginScreen extends StatefulWidget {
  static const id = '/admin_login_screen';
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  LoginValidation validation = LoginValidation();
  PostgreSQLConnection? connection;
  String? userName;
  String? password;

  var passwordHint = '';

  @override
  void initState() {
    super.initState();
  }

  _navigate() {
    Navigator.pushNamed(context, ReportScreen.id);
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: const Text('ADMIN LOGIN'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: SizedBox(
                width: 200.0,
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
                      title: 'LOGIN',
                      onPressed: () async {
                        bool? error;
                        var formValidated =
                        _formKey.currentState!.validate();
                        if (formValidated) {
                          error = await DbManager.fetchLoginCreds(userName!, 0, 'ADMIN');
                          if (error == true) {
                            showSnackbar("Invalid Username");
                            error = false;
                          } else if (error == false) {
                            error = await DbManager.fetchLoginCreds(password!, 1, 'ADMIN');
                            if (error == false) {
                              DbManager.userName = userName;
                              _navigate();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Login Successful.'),
                                ),
                              );
                              formValidated = false;
                            } else {
                              fetchPasswordHint();
                              showSnackbar("Invalid password.");
                              error = false;
                            }
                          }
                        }
                      },
                    ),
                    Text('$passwordHint ')
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  void fetchPasswordHint() async {
    List<List<dynamic>> username = await DbManager.connection!.query(
        "SELECT PASSWORD_HINT FROM ADMIN WHERE USERNAME = @USERNAME",
        substitutionValues: {
          "USERNAME": userName
        });
    setState(() {
      passwordHint = "Password Hint : " + username[0][0];
    });
  }
}
