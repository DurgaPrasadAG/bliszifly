import 'package:flutter/material.dart';

class BlisUnderLineTextFormField extends StatelessWidget {
   const BlisUnderLineTextFormField({
    Key? key,
    required this.title,
    this.maxLines = 1,
    this.autofocus = false,
    this.readOnly = false,
    required this.validator, this.controller
  }) : super(key: key);

  final TextEditingController? controller;
  final int maxLines;
  final String title;
  final bool autofocus;
  final bool readOnly;
  final Function validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              labelText: title,),
          autofocus: autofocus,
          readOnly: readOnly,
          validator: (value) {
            return validator(value);
          },
          maxLength: 100,
        ),
        const SizedBox(height: 10,)
      ],
    );
  }
}
