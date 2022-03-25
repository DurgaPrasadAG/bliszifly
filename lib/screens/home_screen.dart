import 'package:bliszifly/components/category_item.dart';
import 'package:bliszifly/components/change_password_widget.dart';
import 'package:bliszifly/information_categories.dart';
import 'package:bliszifly/models/data_search.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const id = '/home_screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLIS'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: DataSearch(value: Blis.blisSearch));
            },
            icon: const Icon(Icons.search),
            tooltip: 'Blis Search',
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  shape: RoundRect.shape,
                  context: context,
                  builder: (context) => ChangePasswordWidget(
                        who: 'BLIS_USER',
                      ));
            },
            icon: const Icon(Icons.short_text),
            tooltip: 'Change password',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log out',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully.'),
                ),
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView(
          children: categories
              .map(
                (catData) => CategoryItem(
                  id: catData.id,
                  title: catData.title,
                  color: catData.color,
                  onTap: () {
                    return Navigator.pushNamed(context, catData.id);
                  },
                ),
              )
              .toList(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 500,
            childAspectRatio: 1.5,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
        ),
      ),
    );
  }
}
