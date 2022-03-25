import 'package:bliszifly/components/textfield_widget.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/validations/signup_validation.dart';
import 'package:flutter/material.dart';

class ChangePasswordWidget extends StatelessWidget {
  ChangePasswordWidget({
    Key? key, required this.who,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  final String who;
  _updatePassword(String password, String passwordHint) async {
    await DbManager.connection!.execute(
        "UPDATE " + who +
        """ SET PASSWORD = @password, PASSWORD_HINT = @passHint 
        WHERE USERNAME = @username""", substitutionValues: {
      "password": password,
      "passHint": passwordHint,
      "username": DbManager.userName
    });
  }

  @override
  Widget build(BuildContext context) {
    String? password, passwordHint;

    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "CHANGE PASSWORD",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              width: 225,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  BlisTextFormField(
                      obscureText: true,
                      text: 'New Password',
                      validator: (String? value) {
                        password = value;
                        return SignUpValidation.passwordValidation(value);
                      }),
                  BlisTextFormField(
                      obscureText: true,
                      text: 'Confirm Password',
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm password";
                        } else if (value != password) {
                          return "Password didn't match";
                        }
                        return null;
                      }),
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
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _updatePassword(password!, passwordHint!);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password Changed successfully.'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'DONE',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
