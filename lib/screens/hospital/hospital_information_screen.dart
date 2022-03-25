import 'dart:typed_data';

import 'package:bliszifly/components/information_screen_widgets.dart';
import 'package:bliszifly/components/report_bottom_sheet.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/screens/hospital/hospital_form_screen.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

class HospitalInformationScreen extends StatefulWidget {
  const HospitalInformationScreen({Key? key, this.title, this.blisId})
      : super(key: key);
  static const id = '/hospital_info_screen';
  final String? title;
  final String? blisId;

  @override
  _HospitalInformationScreenState createState() =>
      _HospitalInformationScreenState();
}

class _HospitalInformationScreenState extends State<HospitalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  List<List<dynamic>> hospitalList = [];
  List<List<dynamic>> blisList = [];
  List<List<dynamic>> contributionList = [];
  String? doctorName,
      specialization,
      phNum,
      activeHours,
      address,
      contributor,
      description;

  Uint8List? image;
  String? reason;

  @override
  void initState() {
    _fetchHospitalInformation();
    super.initState();
  }

  Future _fetchHospitalInformation() async {
    hospitalList = await DbManager.connection!.query("""
        SELECT DOCTOR_NAME, SPECIALIZATION, CONTACT_NUM
        FROM HOSPITAL WHERE HOSPITAL_ID = @HOSPITAL_ID
        """, substitutionValues: {"HOSPITAL_ID": widget.blisId});

    blisList = await DbManager.connection!.query("""
      SELECT IMAGE, ACTIVE_HOURS, ADDRESS, DESCRIPTION 
      FROM BLIS WHERE BLIS_ID = @BLIS_ID
    """, substitutionValues: {"BLIS_ID": widget.blisId});

    contributionList = await DbManager.connection!.query("""
      SELECT USERNAME FROM CONTRIBUTOR
      WHERE CONTRIBUTED_DATE IN 
      (SELECT MIN(CONTRIBUTED_DATE)
      FROM CONTRIBUTOR)
    """);

    setState(() {
      String msg = 'Data Not Available.';
      doctorName = hospitalList[0][0] == '' ? msg : hospitalList[0][0];
      specialization = hospitalList[0][1] == '' ? msg : hospitalList[0][1];
      phNum = hospitalList[0][2];
      image = Uint8List.fromList(blisList[0][0]);
      activeHours = blisList[0][1];
      address = blisList[0][2];
      description = blisList[0][3];
      contributor = contributionList.isEmpty ? msg : contributionList[0][0];
    });
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HospitalFormScreen(
                    hospName: widget.title,
                    doctorName:
                        doctorName == 'Data Not Available.' ? '' : doctorName,
                    specialization: specialization == 'Data Not Available.'
                        ? ''
                        : specialization,
                    phNum: phNum,
                    activeHours: activeHours,
                    address: address,
                    description: description,
                    image: image,
                    action: 1,
                    title: 'Modify Hospital',
                    heading: 'MODIFY',
                    blisId: widget.blisId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Modify Data',
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) => BuildSheet(formKey: _formKey, blisId: widget.blisId!),
                  shape: RoundRect.shape,
              );
            },
            icon: const Icon(Icons.report),
            tooltip: 'Report this info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder(
                future: _fetchHospitalInformation(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return BlisImageWidget(
                      bytes: snapshot.data,
                    );
                  } else {
                    return const SizedBox(
                      width: 300,
                      height: 300,
                      child: Text('Loading Image...'),
                    );
                  }
                },
              ),
              BlisAttributeWidget(
                attributeName: 'Doctor Name',
                attributeValue: doctorName ?? 'Loading Data...',
              ),
              BlisAttributeWidget(
                attributeName: 'Specialization',
                attributeValue: specialization ?? 'Loading Data...',
              ),
              BlisAttributeWidget(
                attributeName: 'Phone Number',
                attributeValue: phNum ?? 'Loading Data...',
              ),

              BlisAttributeWidget(
                attributeName: 'Active hours',
                attributeValue: activeHours ?? 'Loading Data...',
              ),
              BlisAttributeWidget(
                attributeName: 'Address',
                attributeValue: address ?? 'Loading Data...',
              ),
              BlisAttributeWidget(
                attributeName: 'Description',
                attributeValue: description ?? 'Loading Data...',
              ),
              BlisAttributeWidget(
                attributeName: 'Contributed By',
                attributeValue: contributor ?? 'Loading Data...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
