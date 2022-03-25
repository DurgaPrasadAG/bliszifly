import 'package:bliszifly/data/education_category.dart';
import 'package:bliszifly/models/data_search.dart';
import 'package:bliszifly/screens/education/edu_info_screen_main.dart';
import 'package:bliszifly/screens/education/education_form_screen.dart';
import 'package:flutter/material.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);
  static const id = '/education_screen';

  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: DataSearch(value: Blis.education));
              },
              icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: buildScreens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          ...EduNavBarItems.items.map(
                  (e) => BottomNavigationBarItem(icon: Icon(e.icon), label: e.label)).toList()
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EducationFormScreen(
                title: 'Add new Education',
                heading: 'NEW',
                action: 0,
              ),
            ),
          );
        },
      ),
    );
  }

  List buildScreens() {
    var screens = [];
    for (int i = 0; i < EduNavBarItems.items.length; i++) {
      screens.add(EduInfoScreenMain(
        cat: EduNavBarItems.items[i].label,
        icon: EduNavBarItems.items[i].icon,
      ));
    }
    return screens;
  }
}
