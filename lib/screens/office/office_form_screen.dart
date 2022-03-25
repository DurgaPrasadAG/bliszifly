import 'dart:typed_data';

import 'package:bliszifly/components/elevated_button_widget.dart';
import 'package:bliszifly/components/text_widget.dart';
import 'package:bliszifly/components/textfield_widget.dart';
import 'package:bliszifly/components/underlined_text_form_field_widget.dart';
import 'package:bliszifly/data/office_category.dart';
import 'package:bliszifly/validations/post_validation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:postgres/postgres.dart';

class OfficeFormScreen extends StatefulWidget {
  const OfficeFormScreen(
      {Key? key,
      this.action,
      this.blisId,
      this.officeName,
      this.category,
      this.phNum,
      this.activeHours,
      this.address,
      this.description,
      this.image,
      this.title,
      this.heading})
      : super(key: key);
  static const id = '/office_form_screen';

  final int? action;
  final String? blisId;
  final String? officeName, category, phNum, activeHours, address, description;

  final Uint8List? image;
  final String? title, heading;

  @override
  _OfficeFormScreenState createState() => _OfficeFormScreenState();
}

class _OfficeFormScreenState extends State<OfficeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final validate = PostValidation();
  String dropdownValue = 'Uncategorized';

  FilePickerResult? result;
  String? file;
  String? fileName;

  final _officeNC = TextEditingController();
  final _phNumNC = TextEditingController();
  final _activeNC = TextEditingController();
  final _addressNC = TextEditingController();
  final _fileNC = TextEditingController();
  final _descriptionNC = TextEditingController();

  final categoryList = OfficeCategory.category;

  String? offName, phNum, activeHours, address, description;

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  _updateFileName(String value) {
    setState(() {
      _fileNC.text = value;
    });
  }

  Future<bool?> addOffice() async {
    bool? success;
    int? blisId = await DbManager.addToBlis(
        file!, description!, activeHours!, address!, "OFFICE");

    if (blisId != null) {
      try {
        await DbManager.connection!.execute(
          """
        INSERT INTO OFFICE
        VALUES (@OFFICE_ID, @OFFICE_NAME, @CATEGORY, @CONTACT_NUM)
        """,
          substitutionValues: {
            "OFFICE_ID": blisId,
            "OFFICE_NAME": offName,
            "CATEGORY": dropdownValue,
            "CONTACT_NUM": phNum == '' ? null : phNum,
          },
        );
        success = true;
      } on PostgreSQLException {
        success = false;
        _showSnackbar("Either Office name or Phone Number is not unique");
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

  Future<bool?> modifyOffice() async {
    bool? success;

    try {
      await DbManager.connection!.execute(
        """
        UPDATE OFFICE
        SET OFFICE_NAME = @OFFICE_NAME, CATEGORY = @CATEGORY, 
        CONTACT_NUM = @CONTACT_NUM
        WHERE OFFICE_ID = @OFFICE_ID
        """,
        substitutionValues: {
          "OFFICE_NAME": offName,
          "CATEGORY": dropdownValue,
          "CONTACT_NUM": phNum == '' ? null : phNum,
          "OFFICE_ID": widget.blisId
        },
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
      _showSnackbar("Either Office name or Phone Number is not unique");
    }

    if (success && _fileNC.text != '') {
      try {
        await DbManager.connection!.execute(
          """
        UPDATE BLIS
        SET IMAGE = pg_read_binary_file(@IMAGE)
        WHERE BLIS_ID = @OFFICE_ID
        """,
          substitutionValues: {"IMAGE": file!, "OFFICE_ID": widget.blisId},
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
    _officeNC.text = widget.officeName!;
    _phNumNC.text = widget.phNum ?? '';
    _activeNC.text = widget.activeHours!;
    _addressNC.text = widget.address!;
    _descriptionNC.text = widget.description!;
    dropdownValue = widget.category!;
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
                                controller: _officeNC,
                                text: 'Office Name',
                                validator: (String? value) {
                                  offName = value;
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
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(8, 15, 0, 0),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: dropdownValue,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownValue = newValue!;
                                    });
                                  },
                                  items: categoryList
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 225,
                              child: BlisTextFormField(
                                controller: _phNumNC,
                                text: 'Phone Number',
                                validator: (String? value) {
                                  phNum = value;
                                  return validate.phoneValidation(value);
                                },
                                maxLength: 11,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: SizedBox(
                              width: 225,
                              child: BlisTextFormField(
                                controller: _activeNC,
                                text: 'Active Hours',
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
                                      bool? success = await addOffice();
                                      if (success!) {
                                        Navigator.of(context).pop();
                                        _showSnackbar(
                                            'Office Added Successfully.');
                                      }
                                    } else if (widget.action == 1) {
                                      bool? success = await modifyOffice();
                                      if (success!) {
                                        Navigator.of(context).pop();
                                        _showSnackbar(
                                            'Office Modified Successfully.');
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
