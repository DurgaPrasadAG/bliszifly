import 'dart:typed_data';

import 'package:bliszifly/components/information_screen_widgets.dart';
import 'package:bliszifly/components/report_bottom_sheet.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';
import 'package:bliszifly/screens/park/park_form_screen.dart';

class ParkInformationScreen extends StatefulWidget {
  const ParkInformationScreen({Key? key, this.title, this.blisId})
      : super(key: key);
  final String? title;
  final String? blisId;

  @override
  _ParkInformationScreenState createState() => _ParkInformationScreenState();
}

class _ParkInformationScreenState extends State<ParkInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  List<List<dynamic>> parkList = [];
  List<List<dynamic>> blisList = [];
  List<List<dynamic>> contributionList = [];
  String? parkName,
      activeHours,
      address,
      contributor,
      description;

  Uint8List? image;
  String? reason;

  @override
  void initState() {
    _fetchParkInformation();
    super.initState();
  }

  Future _fetchParkInformation() async {
    parkList = await DbManager.connection!.query("""
        SELECT PARK_NAME
        FROM PARK WHERE PARK_ID = @PARK_ID
        """, substitutionValues: {"PARK_ID": widget.blisId});

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
      parkName = parkList[0][0];
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
                  builder: (context) => ParkFormScreen(
                    parkName: widget.title,
                    activeHours: activeHours,
                    address: address,
                    description: description,
                    image: image,
                    action: 1,
                    title: 'Modify Park',
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
                future: _fetchParkInformation(),
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
