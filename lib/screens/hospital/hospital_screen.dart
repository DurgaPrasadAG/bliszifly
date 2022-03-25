import 'package:bliszifly/models/data_search.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/screens/hospital/hospital_information_screen.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

import 'hospital_form_screen.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({Key? key}) : super(key: key);
  static const id = '/hospital_screen';

  @override
  _HospitalScreenState createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  List<List<dynamic>> hospitalList = [];

  _fetchHospitals() async {
    hospitalList =
        await DbManager.connection!.query("SELECT HOSPITAL_ID, HOSPITAL_NAME FROM HOSPITAL ORDER BY HOSPITAL_NAME");
    setState(() {
      hospitalList.length;
    });
  }

  @override
  void initState() {
    _fetchHospitals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Hospitals'),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch(value: Blis.hospital));
                },
                icon: const Icon(Icons.search_rounded))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: RefreshIndicator(
            onRefresh: () => _fetchHospitals(),
            child: ListView.builder(
                itemCount: hospitalList.length,
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HospitalInformationScreen(
                            blisId: hospitalList[index][0],
                            title: hospitalList[index][1],
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
                            const Icon(Icons.local_hospital),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Text(
                                '${hospitalList[index][1]}',
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 15.0,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) =>
            const HospitalFormScreen(title: 'Add new Hospital', heading: 'NEW', action: 0,))
            );
          },
        ),
    );
  }
}
