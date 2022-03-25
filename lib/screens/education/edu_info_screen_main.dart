import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

import 'education_information_screen.dart';

class EduInfoScreenMain extends StatelessWidget {
  const EduInfoScreenMain({Key? key, required this.cat, required this.icon}) : super(key: key);

  final String cat;
  final IconData icon;

  _fetchEducation(String category) async {
    List<List<dynamic>> educationList = await DbManager.connection!.query("""
      SELECT EDUCATION_ID, EDU_NAME
      FROM EDUCATION
      WHERE CATEGORY = @catVal
      ORDER BY EDU_NAME""", substitutionValues: {"catVal": category});

    return educationList;
  }

  @override
  Widget build(BuildContext context) {
    return buildOfficesName(context, cat, icon);
  }

  FutureBuilder buildOfficesName(BuildContext context, String cat, IconData icon) {
    return FutureBuilder(
        future: _fetchEducation(cat),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () => _fetchEducation(cat),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EducationInformationScreen(
                              blisId: snapshot.data[index][0],
                              title: snapshot.data[index][1],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 15.0,
                        shape: RoundRect.shape,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Icon(icon),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Text(
                                  '${snapshot.data[index][1]}',
                                  style: const TextStyle(fontSize: 25),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          return const Center(
            child: Text(
              'Data not added yet.',
              style: TextStyle(fontSize: 30),
            ),
          );
        }
    );
  }
}
