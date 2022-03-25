import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  const ElevatedButtonWidget({Key? key, required this.title, required this.onPressed}) : super(key: key);

  final Function onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(10.0))
      ),
      child: Text(title,
        style: const TextStyle(
          fontSize: 25.0,
        ),
      ),
    );
  }
}
