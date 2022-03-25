import 'package:flutter/material.dart';

class BlisTextFormField extends StatelessWidget {
   const BlisTextFormField({
    Key? key,
    this.obscureText = false,
    required this.text,
    this.sizedBoxHeight = 10.0,
    this.keyboardType = TextInputType.text,
    required this.validator,
    this.maxLength,
    this.autofocus = false, this.controller
  }) : super(key: key);

  final String text;
  final bool obscureText;
  final double sizedBoxHeight;
  final Function validator;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool autofocus;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          autofocus: autofocus,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: text,
            counterText: ''
          ),
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: (value) {
            return validator(value);
          },
          textInputAction: TextInputAction.next,
          controller: controller,
        ),
        SizedBox(height: sizedBoxHeight),
      ],
    );
  }
}
