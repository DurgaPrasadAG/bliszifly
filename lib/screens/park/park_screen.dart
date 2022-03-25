import 'package:bliszifly/models/data_search.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/screens/park/park_form_screen.dart';
import 'package:bliszifly/screens/park/park_information_screen.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

class ParkScreen extends StatefulWidget {
  const ParkScreen({Key? key}) : super(key: key);
  static const id = '/park_screen';

  @override
  _ParkScreenState createState() => _ParkScreenState();
}

class _ParkScreenState extends State<ParkScreen> {
  List<List<dynamic>> parkList = [];

  _fetchParks() async {
    parkList =
    await DbManager.connection!.query("SELECT PARK_ID, PARK_NAME FROM PARK ORDER BY PARK_NAME");
    setState(() {
      parkList.length;
    });
  }

  @override
  void initState() {
    _fetchParks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parks'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: DataSearch(value: Blis.park));
              },
              icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: () => _fetchParks(),
          child: ListView.builder(
              itemCount: parkList.length,
              itemBuilder: (_, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkInformationScreen(
                          blisId: parkList[index][0],
                          title: parkList[index][1],
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
                          const Icon(Icons.park),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Text(
                              '${parkList[index][1]}',
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
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) =>
          const ParkFormScreen(title: 'Add new Park', heading: 'NEW', action: 0,))
          );
        },
      ),
    );
  }
}
