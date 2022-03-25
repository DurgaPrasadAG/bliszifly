import 'package:bliszifly/components/underlined_text_form_field_widget.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:flutter/material.dart';

class BuildSheet extends StatelessWidget {
  const BuildSheet({Key? key, required this.formKey, required this.blisId})
      : super(key: key);
  final GlobalKey<FormState> formKey;
  final String blisId;

  @override
  Widget build(BuildContext context) {
    return buildSheet(context, formKey, blisId);
  }
}

Widget buildSheet(
    BuildContext context, GlobalKey<FormState> key, String blisId) {
  String? reason;
  return Form(
    key: key,
    child: Column(
      children: [
        const Text(
          'REPORT',
          style: TextStyle(fontSize: 30),
        ),
        SizedBox(
            width: 460,
            child: BlisUnderLineTextFormField(
              title: 'Reason',
              validator: (String? value) {
                reason = value;
                return (value != null && value.isEmpty)
                    ? "Please write the reason."
                    : null;
              },
              maxLines: 5,
            )),
        SizedBox(
          width: 460,
          child: ElevatedButton(
            onPressed: () async {
              if (key.currentState!.validate()) {
                await DbManager.reportUser(blisId, reason!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted successfully.'),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'SUBMIT',
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      ],
    ),
  );
}
