import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/screens/education/education_information_screen.dart';
import 'package:bliszifly/screens/hospital/hospital_information_screen.dart';
import 'package:bliszifly/screens/office/office_information_screen.dart';
import 'package:bliszifly/screens/park/park_information_screen.dart';
import 'package:flutter/material.dart';

enum Blis { blisSearch, hospital, office, park, education }

class DataSearch extends SearchDelegate {
  DataSearch({required this.value}) {
    if (value == Blis.blisSearch) {
      blisQuickSearch = 'Blis Quick Search';
    }
  }

  Blis value;

  final List<String> text = [];

  String? blisId;
  String? blisPlaceName, blisName, blisId2;
  String? select, from;
  String? blisQuickSearch;

  final List<String> bId = [];
  final List<String> cat = [];

  List blisSearchName = [];
  List blisSearchID = [];
  List blisCat = [];
  List<List<dynamic>> hospitalSearch = [];
  List<List<dynamic>> officeSearch = [];
  List<List<dynamic>> parkSearch = [];
  List<List<dynamic>> educationSearch = [];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _deleteBlisSearchTableValues();
          query = '';
        },
        tooltip: 'Clear Search',
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          _deleteBlisSearchTableValues();
          Navigator.of(context).pop();
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    text.clear();
    if (query.isNotEmpty && query.length > 1) {
      return FutureBuilder(
        future: value == Blis.blisSearch
            ? _insertIntoBlisSearchTable()
            : _fetchInformation(query),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                onTap: () async {
                  if (value != Blis.blisSearch) {
                    query = text[index];
                    blisId = await _fetchBlisId(query);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return displayScreen();
                      }),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return displayScreen2(
                            cat[index], text[index], bId[index]);
                      }),
                    );
                  }
                  showResults(context);
                },
                leading: const Icon(Icons.flash_on),
                title: Text(text[index]),
              ),
              itemCount: text.length,
            );
          } else {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Searching...'),
                  )
                ],
              ),
            );
          }
        },
      );
    } else {
      return Center(
        child: Text(
          blisQuickSearch ?? 'Search Now',
          style: const TextStyle(fontSize: 30),
        ),
      );
    }
  }

  _fetchInformation(String query) async {
    fetchBlisDetails();

    List<List<dynamic>> results = await DbManager.connection!.query("SELECT " +
        blisPlaceName! +
        " FROM " +
        blisName! +
        " WHERE " +
        blisPlaceName! +
        " ILIKE '" "" +
        query +
        "%'");

    for (int i = 0, j = 0; i < results.length; i++) {
      text.add(results[i][j]);
    }
    return results;
  }

  Future<String> _fetchBlisId(String query) async {
    List<List<dynamic>> blisId = await DbManager.connection!.query(
        "SELECT " +
            blisId2! +
            " FROM " +
            blisName! +
            " WHERE " +
            blisPlaceName! +
            " = @name" "",
        substitutionValues: {"name": query});

    return blisId[0][0];
  }

  fetchBlisDetails() {
    switch (value) {
      case Blis.hospital:
        blisPlaceName = 'HOSPITAL_NAME';
        blisName = 'HOSPITAL';
        blisId2 = 'HOSPITAL_ID';
        break;
      case Blis.office:
        blisPlaceName = 'OFFICE_NAME';
        blisName = 'OFFICE';
        blisId2 = 'OFFICE_ID';
        break;
      case Blis.park:
        blisPlaceName = 'PARK_NAME';
        blisName = 'PARK';
        blisId2 = 'PARK_ID';
        break;
      case Blis.education:
        blisPlaceName = 'EDU_NAME';
        blisName = 'EDUCATION';
        blisId2 = 'EDUCATION_ID';
        break;
      case Blis.blisSearch:
        break;
    }
  }

  Widget displayScreen() {
    switch (value) {
      case Blis.hospital:
        return HospitalInformationScreen(
          blisId: blisId,
          title: query,
        );
      case Blis.office:
        return OfficeInformationScreen(
          blisId: blisId,
          title: query,
        );
      case Blis.park:
        return ParkInformationScreen(
          blisId: blisId,
          title: query,
        );
      case Blis.education:
        return EducationInformationScreen(
          blisId: blisId,
          title: query,
        );
      case Blis.blisSearch:
        return EducationInformationScreen(
          blisId: blisId,
          title: query,
        );
    }
  }

  _deleteBlisSearchTableValues() async {
    blisSearchName = [];
    blisSearchID = [];
    hospitalSearch = [];
    officeSearch = [];
    parkSearch = [];
    educationSearch = [];
  }

  _insertIntoBlisSearchTable() async {
    _deleteBlisSearchTableValues();

    hospitalSearch = await DbManager.connection!.query("""
        SELECT hospital_name, hospital_id FROM hospital WHERE hospital_name ILIKE '""" +
        query +
        "%'");

    for (int i = 0; i < hospitalSearch.length; i++) {
      blisSearchName.add(hospitalSearch[i][0]);
      blisSearchID.add(hospitalSearch[i][1]);
      blisCat.add("HOSPITAL");
    }

    officeSearch = await DbManager.connection!.query("""
        SELECT office_name, office_id FROM office WHERE office_name ILIKE '""" +
        query +
        "%'");
    for (int i = 0; i < officeSearch.length; i++) {
      blisSearchName.add(officeSearch[i][0]);
      blisSearchID.add(officeSearch[i][1]);
      blisCat.add("OFFICE");
    }

    parkSearch = await DbManager.connection!.query("""
        SELECT park_name, park_id FROM park WHERE park_name ILIKE '""" +
        query +
        "%'");
    for (int i = 0; i < parkSearch.length; i++) {
      blisSearchName.add(parkSearch[i][0]);
      blisSearchID.add(parkSearch[i][1]);
      blisCat.add("PARK");
    }

    educationSearch = await DbManager.connection!.query("""
        SELECT edu_name, education_id FROM education where edu_name ILIKE '""" +
        query +
        "%'");
    for (int i = 0; i < educationSearch.length; i++) {
      blisSearchName.add(educationSearch[i][0]);
      blisSearchID.add(educationSearch[i][1]);
      blisCat.add("EDUCATION");
    }

    if (blisSearchName.isNotEmpty) {
      for (int i = 0; i < blisSearchName.length; i++) {
        text.add(blisSearchName[i]);
        bId.add(blisSearchID[i]);
        cat.add(blisCat[i]);
      }
    }

    return blisSearchName;
  }

  Widget displayScreen2(String category, String name, String id) {
    switch (category) {
      case 'HOSPITAL':
        return HospitalInformationScreen(
          blisId: id,
          title: name,
        );
      case 'OFFICE':
        return OfficeInformationScreen(
          blisId: id,
          title: name,
        );
      case 'PARK':
        return ParkInformationScreen(
          blisId: id,
          title: name,
        );
      case 'EDUCATION':
        return EducationInformationScreen(
          blisId: id,
          title: name,
        );
      default:
        return Container();
    }
  }
}
