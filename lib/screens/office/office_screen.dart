import 'package:bliszifly/data/office_category.dart';
import 'package:bliszifly/models/data_search.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/themes/rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

import 'office_form_screen.dart';
import 'office_information_screen.dart';

class OfficeScreen extends StatefulWidget {
  const OfficeScreen({Key? key}) : super(key: key);
  static const id = '/office_screen';

  @override
  _OfficeScreenState createState() => _OfficeScreenState();
}

class _OfficeScreenState extends State<OfficeScreen> {
  List<List<dynamic>> officeList = [];

  _fetchOffices(String category) async {
    officeList = await DbManager.connection!.query("""
      SELECT OFFICE_ID, OFFICE_NAME
      FROM OFFICE
      WHERE CATEGORY = @catVal
      ORDER BY OFFICE_NAME""", substitutionValues: {"catVal": category});

    return officeList;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: OfficeCategory.category.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offices'),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch(value: Blis.office));
                },
                icon: const Icon(Icons.search_rounded))
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [...OfficeCategory.category.map((e) => Tab(text: e)).toList()],
          ),
        ),
        body: buildTabBarView(context),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OfficeFormScreen(
                  title: 'Add new Office',
                  heading: 'NEW',
                  action: 0,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  TabBarView buildTabBarView(BuildContext context) {
    List<Widget> categoryWidgets = [];
    for (final i in OfficeCategory.category) {
      categoryWidgets.add(buildOfficesName(context, i));
    }

    return TabBarView(
      children: [...categoryWidgets.toList()],
    );
  }

  FutureBuilder buildOfficesName(BuildContext context, String cat) {
    return FutureBuilder(
      future: _fetchOffices(cat),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () => _fetchOffices(cat),
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
                            builder: (context) => OfficeInformationScreen(
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
                              const Icon(Icons.business),
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
