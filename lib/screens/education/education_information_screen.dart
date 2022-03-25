import 'dart:typed_data';

import 'package:bliszifly/components/information_screen_widgets.dart';
import 'package:bliszifly/components/report_bottom_sheet.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/screens/education/education_form_screen.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

class EducationInformationScreen extends StatefulWidget {
  const EducationInformationScreen({Key? key, this.title, this.blisId}) : super(key: key);
  final String? title;
  final String? blisId;

  @override
  _EducationInformationScreenState createState() => _EducationInformationScreenState();
}

class _EducationInformationScreenState extends State<EducationInformationScreen> {
  final formKey = GlobalKey<FormState>();
  List<List<dynamic>> eduList = [];
  List<List<dynamic>> blisList = [];
  List<List<dynamic>> contributionList = [];
  String? eduName,
      category,
      phNum,
      activeHours,
      address,
      contributor,
      description;

  Uint8List? image;
  String? reason;

  @override
  void initState() {
    super.initState();
    _fetchEduInformation();
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
                  builder: (context) => EducationFormScreen(
                    eduName: widget.title,
                    category: category,
                    phNum: phNum,
                    activeHours: activeHours,
                    address: address,
                    description: description,
                    image: image,
                    action: 1,
                    title: 'Modify Education',
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
                builder: (context) => BuildSheet(formKey: formKey, blisId: widget.blisId!),
                shape: RoundRect.shape,
              );
            },
            icon: const Icon(Icons.report),
            tooltip: 'Report this info',
          ),
        ],
      ),
      body: buildSingleChildScrollView(),
    );
  }

  SingleChildScrollView buildSingleChildScrollView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: _fetchEduInformation(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
              attributeName: 'Category',
              attributeValue: category ?? 'Loading Data...',
            ),
            BlisAttributeWidget(
              attributeName: 'Phone Number',
              attributeValue: phNum ?? 'Data Not Available.',
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
    );
  }

  Future _fetchEduInformation() async {
    eduList = await DbManager.connection!.query("""
        SELECT EDU_NAME, CATEGORY, CONTACT_NUM
        FROM EDUCATION WHERE EDUCATION_ID = @EDUCATION_ID
        """, substitutionValues: {"EDUCATION_ID": widget.blisId});

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
      eduName = eduList[0][0];
      category = eduList[0][1];
      phNum = eduList[0][2];
      image = Uint8List.fromList(blisList[0][0]);
      activeHours = blisList[0][1];
      address = blisList[0][2];
      description = blisList[0][3];
      contributor = contributionList.isEmpty ? msg : contributionList[0][0];
    });
    return image;
  }
}
