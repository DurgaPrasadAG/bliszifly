import 'dart:typed_data';

import 'package:bliszifly/components/elevated_button_widget.dart';
import 'package:bliszifly/components/text_widget.dart';
import 'package:bliszifly/components/textfield_widget.dart';
import 'package:bliszifly/components/underlined_text_form_field_widget.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/validations/post_validation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class ParkFormScreen extends StatefulWidget {
  const ParkFormScreen(
      {Key? key,
      this.action,
      this.blisId,
      this.parkName,
      this.activeHours,
      this.address,
      this.description,
      this.image,
      this.title,
      this.heading})
      : super(key: key);
  static const id = '/park_form_screen';

  final int? action;
  final String? blisId;
  final String? parkName, activeHours, address, description;

  final Uint8List? image;
  final String? title, heading;

  @override
  _ParkFormScreenState createState() => _ParkFormScreenState();
}

class _ParkFormScreenState extends State<ParkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final validate = PostValidation();

  FilePickerResult? result;
  String? file;
  String? fileName;

  final _parkNC = TextEditingController();
  final _activeNC = TextEditingController();
  final _addressNC = TextEditingController();
  final _fileNC = TextEditingController();
  final _descriptionNC = TextEditingController();

  String? parkName, activeHours, address, description;

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  _updateFileName(String value) {
    setState(() {
      _fileNC.text = value;
    });
  }

  Future<bool?> addPark() async {
    bool? success;
    int? blisId = await DbManager.addToBlis(
        file!, description!, activeHours!, address!, "PARK");

    if (blisId != null) {
      try {
        await DbManager.connection!.execute(
          """
        INSERT INTO PARK
        VALUES (@PARK_ID, @PARK_NAME)
        """,
          substitutionValues: {
            "PARK_ID": blisId,
            "PARK_NAME": parkName,
          },
        );
        success = true;
      } on PostgreSQLException {
        success = false;
        _showSnackbar("Park name must be unique.");
      }
    } else {
      success = false;
    }

    if (success) {
      try {
        await DbManager.connection!.execute(
          """
        INSERT INTO CONTRIBUTOR
        VALUES (@CONTRIBUTOR_ID, current_date, LOCALTIME, @USERNAME)
        """,
          substitutionValues: {
            "CONTRIBUTOR_ID": blisId,
            "USERNAME": DbManager.userName,
          },
        );
        success = true;
      } on PostgreSQLException {
        success = false;
        _showSnackbar("This shouldn't happen.");
      }
    }

    return success;
  }

  Future<bool?> modifyPark() async {
    bool? success;

    try {
      await DbManager.connection!.execute(
        """
        UPDATE PARK
        SET PARK_NAME = @PARK_NAME
        WHERE PARK_ID = @PARK_ID
        """,
        substitutionValues: {"PARK_NAME": parkName, "PARK_ID": widget.blisId},
      );

      await DbManager.connection!.execute(
        """
        UPDATE BLIS
        SET DESCRIPTION = @desc, ACTIVE_HOURS = @activeHours, 
        ADDRESS = @address
        WHERE BLIS_ID = @blisId
        """,
        substitutionValues: {
          "desc": description,
          "activeHours": activeHours,
          "address": address,
          "blisId": widget.blisId
        },
      );
      success = true;
    } on PostgreSQLException {
      success = false;
      _showSnackbar("Park name must be unique.");
    }

    if (success && _fileNC.text != '') {
      try {
        await DbManager.connection!.execute(
          """
        UPDATE BLIS
        SET IMAGE = pg_read_binary_file(@IMAGE)
        WHERE BLIS_ID = @PARK_ID
        """,
          substitutionValues: {"IMAGE": file!, "PARK_ID": widget.blisId},
        );
        success = true;
      } on PostgreSQLException {
        success = false;
        _showSnackbar("This image is not supported.");
      }
    }

    if (success) {
      try {
        await DbManager.connection!.execute(
          """
        INSERT INTO CONTRIBUTOR
        VALUES (@CONTRIBUTOR_ID, current_date, LOCALTIME, @USERNAME)
        """,
          substitutionValues: {
            "CONTRIBUTOR_ID": widget.blisId,
            "USERNAME": DbManager.userName,
          },
        );
        success = true;
      } on PostgreSQLException {
        success = false;
        _showSnackbar("This shouldn't happen.");
      }
    }

    return success;
  }

  _setValues() {
    _parkNC.text = widget.parkName!;
    _activeNC.text = widget.activeHours!;
    _addressNC.text = widget.address!;
    _descriptionNC.text = widget.description!;
  }

  @override
  void initState() {
    super.initState();
    if (widget.action == 1) {
      _setValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Builder(
        builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextWidget(text: widget.heading!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 460,
                              child: BlisTextFormField(
                                controller: _parkNC,
                                text: 'Park Name',
                                validator: (String? value) {
                                  parkName = value;
                                  return validate.blisPlaceNameValidation(value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 460,
                              child: BlisTextFormField(
                                controller: _activeNC,
                                text: 'Active hours',
                                validator: (String? value) {
                                  activeHours = value;
                                  return validate.fieldValidation(value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 460,
                              child: BlisTextFormField(
                                controller: _addressNC,
                                text: 'Address',
                                validator: (String? value) {
                                  address = value;
                                  return validate.fieldValidation(value, min10: true);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButtonWidget(
                                title: 'Upload Image',
                                onPressed: () async {
                                  result = await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['jpg', 'jpeg'],
                                      withData: true);
                                  if (result != null) {
                                    file = result!.files.first.path;
                                    _updateFileName(result!.files.first.name);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: SizedBox(
                              width: 250,
                              child: TextFormField(
                                controller: _fileNC,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Filename',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _fileNC.text = '';
                                      });
                                      file = null;
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                                validator: (value) {
                                  if (widget.action == 0) {
                                    if (value == null || value.isEmpty) {
                                      return "Please add an image.";
                                    } else {
                                      return null;
                                    }
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 460,
                              child: BlisUnderLineTextFormField(
                                controller: _descriptionNC,
                                title: 'Description',
                                maxLines: 5,
                                validator: (String? value) {
                                  description = value;
                                  return validate.fieldValidation(value, min10: true);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 460,
                              child: ElevatedButtonWidget(
                                title: 'POST',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (widget.action == 0) {
                                      bool? success = await addPark();
                                      if (success!) {
                                        Navigator.of(context).pop();
                                        _showSnackbar(
                                            'Park Added Successfully.');
                                      }
                                    } else if (widget.action == 1) {
                                      bool? success = await modifyPark();
                                      if (success!) {
                                        Navigator.of(context).pop();
                                        _showSnackbar(
                                            'Park Modified Successfully.');
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
