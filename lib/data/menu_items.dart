import 'package:bliszifly/models/menu_item.dart';
import 'package:flutter/material.dart';

class MenuItems {
  static const List<MenuItem> items= [
    itemChangePassword, itemDeletePost, itemDeleteUser, itemLogOut
  ];

  static const itemChangePassword = MenuItem(text: 'Change Password', icon: Icons.short_text);

  static const itemDeletePost =
      MenuItem(text: 'Delete Post', icon: Icons.delete_sweep);

  static const itemDeleteUser = MenuItem(text: 'Delete user', icon: Icons.delete_sweep_rounded);

  static const itemLogOut = MenuItem(text: 'Log Out', icon: Icons.logout);
}