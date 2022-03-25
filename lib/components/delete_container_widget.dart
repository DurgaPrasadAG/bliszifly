import 'package:bliszifly/components/textfield_widget.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:flutter/material.dart';

class DeleteContainerWidget extends StatelessWidget {
  DeleteContainerWidget({
    Key? key,
    required this.text,
    this.controller,
  }) : super(key: key);
  final String text;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    String what;

    if (text == 'BLIS ID') {
      what = 'A POST';
    } else {
      what = 'AN USER';
    }
    String? id;

    _deleteUser() async {
      await DbManager.connection!.execute(
          'DELETE FROM BLIS_USER WHERE USERNAME = @username',
          substitutionValues: {"username": id});
    }

    _deletePost() async {
      await DbManager.connection!.execute(
          'DELETE FROM BLIS WHERE BLIS_ID = @blisId',
          substitutionValues: {"blisId": id});
    }

    return Form(
      key: _formKey,
      child: Center(
        child: SizedBox(
          width: 275,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                  child: Text(
                "DELETE $what",
                style: const TextStyle(fontSize: 30),
              )),
              const SizedBox(
                height: 10,
              ),
              BlisTextFormField(
                  controller: controller,
                  text: text,
                  validator: (String? value) {
                    id = value;
                    return (value == null || value.isEmpty)
                        ? "This field is required"
                        : null;
                  }),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (what == 'AN USER') {
                      await _deleteUser();
                    } else {
                      await _deletePost();
                    }
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully deleted $what'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
