import 'package:bliszifly/models/edu_nav_bar_item.dart';
import 'package:flutter/material.dart';

class EduNavBarItems {
  static const List<EduNavBarItem> items =
  [itemSchool, itemCollege, itemEngineering, itemUncategorized];

  static const itemSchool = EduNavBarItem(label: 'School', icon: Icons.backpack);
  static const itemCollege = EduNavBarItem(label: 'PU', icon: Icons.business);
  static const itemEngineering = EduNavBarItem(label: 'Engineering', icon: Icons.school);
  static const itemUncategorized = EduNavBarItem(label: 'Uncategorized', icon: Icons.home_work);
}