import 'package:bliszifly/screens/education/education_screen.dart';
import 'package:bliszifly/screens/hospital/hospital_screen.dart';
import 'package:bliszifly/screens/office/office_screen.dart';
import 'package:bliszifly/screens/park/park_screen.dart';
import 'package:flutter/material.dart';
import './models/category.dart';

const categories = [
  Category(id: HospitalScreen.id, title: "Hospitals", color: Colors.amber),
  Category(id: OfficeScreen.id, title: "Offices", color: Colors.lightGreen),
  Category(id: ParkScreen.id, title: "Parks", color: Colors.cyanAccent),
  Category(id: EducationScreen.id, title: "Education", color: Colors.orange),
];
