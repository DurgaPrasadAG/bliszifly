import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/screens/admin/admin_login_screen.dart';
import 'package:bliszifly/screens/admin/report_screen.dart';
import 'package:bliszifly/screens/education/education_form_screen.dart';
import 'package:bliszifly/screens/hospital/hospital_form_screen.dart';
import 'package:bliszifly/screens/office/office_form_screen.dart';
import 'package:bliszifly/screens/park/park_form_screen.dart';
import 'package:bliszifly/screens/education/education_screen.dart';
import 'package:bliszifly/screens/home_screen.dart';
import 'package:bliszifly/screens/hospital/hospital_screen.dart';
import 'package:bliszifly/screens/hospital/hospital_information_screen.dart';
import 'package:bliszifly/screens/account/login_screen.dart';
import 'package:bliszifly/screens/office/office_screen.dart';
import 'package:bliszifly/screens/park/park_screen.dart';
import 'package:bliszifly/screens/account/signup_screen.dart';
import 'package:bliszifly/screens/welcome_screen.dart';
import 'package:bliszifly/themes/material_app_theme.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';

import 'models/custom_scroll_behaviour.dart';

void main() {
  runApp(const Bliszifly());
  DesktopWindow.setMinWindowSize(const Size(350, 700));
  DesktopWindow.setMaxWindowSize(const Size(560, 970));
  DbManager().connect();
}

class Bliszifly extends StatefulWidget {
  const Bliszifly({Key? key}) : super(key: key);

  @override
  _BlisziflyState createState() => _BlisziflyState();
}

class _BlisziflyState extends State<Bliszifly> {
  ThemeData lightTheme = MaterialTheme.materialLightTheme;
  ThemeData darkTheme = MaterialTheme.materialDarkTheme;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: WelcomeScreen.id,
      scrollBehavior: MyCustomScrollBehavior(),
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        AdminLoginScreen.id: (context) => const AdminLoginScreen(),
        SignupScreen.id: (context) => const SignupScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        HospitalScreen.id: (context) => const HospitalScreen(),
        OfficeScreen.id: (context) => const OfficeScreen(),
        ParkScreen.id: (context) => const ParkScreen(),
        EducationScreen.id: (context) => const EducationScreen(),
        HospitalFormScreen.id: (context) => const HospitalFormScreen(),
        OfficeFormScreen.id:(context) => const OfficeFormScreen(),
        ParkFormScreen.id: (context) => const ParkFormScreen(),
        EducationFormScreen.id: (context) => const EducationFormScreen(),
        HospitalInformationScreen.id: (context) => const HospitalInformationScreen(),
        ReportScreen.id: (context) => const ReportScreen()
      },
    );
  }
}
