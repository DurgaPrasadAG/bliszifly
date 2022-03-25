import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({required this.id, required this.title, required this.color, Key? key, required this.onTap}) : super(key: key);

  final String id;
  final String title;
  final Color color;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Text(
              title,
              style: const TextStyle(
                fontSize: 24.0,
                color: Colors.black
              )
          ),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            color.withOpacity(0.7),
            color
          ], begin: Alignment.topLeft,
            end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(15)
        ),
      ),
    );
  }
}
