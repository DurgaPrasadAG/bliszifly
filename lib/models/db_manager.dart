import 'package:postgres/postgres.dart';

class DbManager {
  static PostgreSQLConnection? connection;
  static String? userName;

  Future<void> connect() async {
    connection = PostgreSQLConnection("localhost", 5432, "dbname",
        username: "username", password: "password");
    await connection!.open();
    await connection!.query("SET TIME ZONE 'ASIA/KOLKATA'");
  }

  static Future<bool?> fetchLoginCreds(
      String name, int whatCreds, String who) async {
    bool? error;
    List<List<dynamic>> results = [];
    userName = name;

    if (whatCreds == 0) {
      results = await connection!.query(
          "SELECT USERNAME FROM $who WHERE USERNAME = @userName",
          substitutionValues: {"userName": name});
    } else if (whatCreds == 1) {
      results = await connection!.query(
          "SELECT PASSWORD FROM $who WHERE PASSWORD = @password",
          substitutionValues: {"password": name});
    }

    String? value;
    for (final row in results) {
      value = row[0];
    }

    error = (name == value) ? false : true;
    return error;
  }

  static void disconnect() {
    connection!.close();
  }

  static Future<int?> addToBlis(String imagePath, String desc,
      String activeHours, String address, String category) async {
    List<List<dynamic>> latestBlisId = [];
    int? blisId;

    latestBlisId = await connection!.query("SELECT MAX(BLIS_ID) FROM BLIS");

    String? tempVal;
    for (final row in latestBlisId) {
      tempVal = row[0];
    }

    if (tempVal != null) {
      blisId = int.parse(tempVal);
    }

    blisId = (blisId == null) ? 1 : ++blisId;

    await DbManager.connection!.execute("""
        INSERT INTO BLIS
        VALUES (@BLIS_ID, pg_read_binary_file(@IMAGE), 
                @DESCRIPTION, @ACTIVE_HOURS, @ADDRESS, @CATEGORY)
        """, substitutionValues: {
      "BLIS_ID": blisId,
      "IMAGE": imagePath,
      "DESCRIPTION": desc,
      "ACTIVE_HOURS": activeHours,
      "ADDRESS": address,
      "CATEGORY": category
    });

    return blisId;
  }

  static Future reportUser(var blisId, String reason) async {
    List<List<dynamic>> latestReportId = [];
    int? reportId;

    latestReportId =
        await DbManager.connection!.query("SELECT MAX(REPORT_ID) FROM REPORT");

    String? tempVal;
    for (final row in latestReportId) {
      tempVal = row[0];
    }

    if (tempVal != null) {
      reportId = int.parse(tempVal);
    }

    reportId = (reportId == null) ? 1 : ++reportId;

    await DbManager.connection!.execute("""
        INSERT INTO REPORT
        VALUES (@REPORT_ID, @BLIS_ID, @REASON, @REPORTED_BY)
        """, substitutionValues: {
      "REPORT_ID": reportId,
      "BLIS_ID": blisId,
      "REASON": reason,
      "REPORTED_BY": DbManager.userName
    });
  }
}
