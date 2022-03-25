import 'package:bliszifly/components/change_password_widget.dart';
import 'package:bliszifly/components/delete_container_widget.dart';
import 'package:bliszifly/components/information_screen_widgets.dart';
import 'package:bliszifly/data/menu_items.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/models/menu_item.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);
  static const id = '/report_screen';

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<List<dynamic>> reportIDList = [];
  List<List<dynamic>> report = [];
  List<List<dynamic>> contributors = [];
  List<String?> contributorName = ['', '', '', '', ''];
  String? reportId, blisId, blisName, blisCategory;

  final _blisIDC = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _fetchReportID() async {
    reportIDList = await DbManager.connection!
        .query("SELECT REPORT_ID, BLIS_ID FROM REPORT ORDER BY REPORT_ID");

    setState(() {
      reportIDList.length;
    });
  }

  _fetchReports() async {
    contributorName = ['', '', '', '', ''];
    report = await DbManager.connection!.query(
        "SELECT REASON, BLIS_ID, REPORTED_BY FROM REPORT WHERE REPORT_ID = @reportValue",
        substitutionValues: {"reportValue": reportId});

    List<List<dynamic>> category = await DbManager.connection!.query(
        "SELECT CATEGORY FROM BLIS WHERE BLIS_ID = @blisId",
        substitutionValues: {"blisId": blisId});

    String? colName, tableName, id;

    switch (category[0][0]) {
      case "HOSPITAL":
        colName = 'HOSPITAL_NAME';
        tableName = 'HOSPITAL';
        id = 'HOSPITAL_ID';
        break;
      case "OFFICE":
        colName = 'OFFICE_NAME';
        tableName = 'OFFICE';
        id = 'OFFICE_ID';
        break;
      case "PARK":
        colName = 'PARK_NAME';
        tableName = 'PARK';
        id = 'PARK_ID';
        break;
      case "EDUCATION":
        colName = 'EDU_NAME';
        tableName = 'EDUCATION';
        id = 'EDUCATION_ID';
        break;
    }

    List<List<dynamic>> blisNameList = await DbManager.connection!.query(
        "SELECT " +
            colName! +
            " FROM " +
            tableName! +
            " WHERE + " +
            id! +
            " = @blisId",
        substitutionValues: {"blisId": blisId});
    blisName = blisNameList[0][0];
    blisCategory = category[0][0];

    contributors = await DbManager.connection!.query("""
        SELECT USERNAME FROM CONTRIBUTOR
        WHERE BLIS_ID = @blisValue
        ORDER BY CONTRIBUTED_DATE DESC, CONTRIBUTED_TIME DESC
        FETCH FIRST 5 ROWS ONLY;
        """, substitutionValues: {"blisValue": blisId});
    for (int i = 0, j = 0; i < contributors.length; i++) {
      contributorName[i] = contributors[i][j];
    }
    setState(() {
      reportIDList.length;
    });
  }

  _deleteReport() async {
    await DbManager.connection!.query(
        "DELETE FROM REPORT WHERE REPORT_ID = @reportValue",
        substitutionValues: {"reportValue": reportId});
  }

  @override
  void initState() {
    _fetchReportID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Reports'),
        actions: <Widget>[
          PopupMenuButton<MenuItem>(
              onSelected: (item) => onSelected(context, item),
              itemBuilder: (context) {
                return [...MenuItems.items.map(builtItem).toList()];
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: () => _fetchReportID(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: reportIDList.length,
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () async {
                  reportId = reportIDList[index][0];
                  blisId = reportIDList[index][1];
                  await _fetchReports();
                  showModalBottomSheet(
                      shape: RoundRect.shape,
                      context: context,
                      builder: (context) => reportSheet(),
                      isScrollControlled: true);
                },
                child: Card(
                  elevation: 8.0,
                  shape: RoundRect.shape,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.report),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          '${reportIDList[index][0]}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget reportSheet() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlisAttributeWidget(
                attributeName: 'REASON',
                attributeValue: "${report.isEmpty ? '' : report[0][0]}"),
            BlisAttributeWidget(
                attributeName: 'BLIS ID',
                attributeValue: "${report.isEmpty ? '' : report[0][1]}"),
            BlisAttributeWidget(
                attributeName: 'BLIS NAME', attributeValue: "$blisName"),
            BlisAttributeWidget(
                attributeName: 'CATEGORY', attributeValue: "$blisCategory"),
            BlisAttributeWidget(
                attributeName: 'REPORTED BY',
                attributeValue: "${report.isEmpty ? '' : report[0][2]}"),
            const SizedBox(
              height: 10,
            ),
            Card(
              elevation: 15.0,
              shape: RoundRect.shape,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                      child: Text(
                    'TOP 5 CONTRIBUTORS',
                    style: TextStyle(fontSize: 25),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  contributorsName(0),
                  contributorsName(1),
                  contributorsName(2),
                  contributorsName(3),
                  contributorsName(4),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        _blisIDC.text = report.isEmpty ? '' : report[0][1];
                        deletePost();
                      },
                      child: const Text(
                        'DELETE POST',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        removeUser();
                      },
                      child: const Text(
                        'REMOVE A USER',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteReport();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report ID successfully deleted.'),
                  ),
                );
              },
              child: const Text(
                'DELETE THIS REPORT',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding contributorsName(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${contributorName[index]}',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  PopupMenuItem<MenuItem> builtItem(MenuItem item) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    Color color = isDarkMode ? Colors.white : Colors.black;
    setState(() => color);

    return PopupMenuItem(
      value: item,
      child: Row(
        children: [
          Icon(item.icon, color: color),
          const SizedBox(
            width: 10,
          ),
          Text(item.text),
        ],
      ),
    );
  }

  onSelected(BuildContext context, item) {
    switch (item) {
      case MenuItems.itemDeletePost:
        deletePost();
        break;
      case MenuItems.itemDeleteUser:
        removeUser();
        break;
      case MenuItems.itemLogOut:
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out Successfully.'),
          ),
        );
        break;
      case MenuItems.itemChangePassword:
        showModalBottomSheet(
            shape: RoundRect.shape,
            context: context,
            builder: (context) => ChangePasswordWidget(
                  who: 'ADMIN',
                ));
        break;
    }
  }

  deletePost() {
    showModalBottomSheet(
      shape: RoundRect.shape,
      context: context,
      builder: (context) => DeleteContainerWidget(
        controller: _blisIDC,
        text: 'BLIS ID',
      ),
    );
  }

  removeUser() {
    showModalBottomSheet(
      shape: RoundRect.shape,
      context: context,
      builder: (context) => DeleteContainerWidget(
        text: 'username',
      ),
    );
  }
}