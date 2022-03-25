import 'dart:typed_data';

import 'package:bliszifly/components/elevated_button_widget.dart';
import 'package:bliszifly/components/text_widget.dart';
import 'package:bliszifly/components/textfield_widget.dart';
import 'package:bliszifly/components/underlined_text_form_field_widget.dart';
import 'package:bliszifly/data/education_category.dart';
import 'package:bliszifly/models/db_manager.dart';
import 'package:bliszifly/models/edu_nav_bar_item.dart';
import 'package:bliszifly/validations/post_validation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class EducationFormScreen extends StatefulWidget {
  const EducationFormScreen({Key? key, this.action, this.blisId, this.eduName, this.category, this.phNum, this.activeHours, this.address, this.description, this.image, this.title, this.heading}) : super(key: key);
  static const id = '/education_form_Screen';

  final int? action;
  final String? blisId;
  final String? eduName, category, phNum, activeHours, address, description;

  final Uint8List? image;
  final String? title, heading;

  @override
  _EducationFormScreenState createState() => _EducationFormScreenState();
}

class _EducationFormScreenState extends State<EducationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final validate = PostValidation();
  String dropdownValue = 'Uncategorized';

  FilePickerResult? result;
  String? file;
  String? fileName;

  final _eduNC = TextEditingController();
  final _phNumNC = TextEditingController();
  final _activeNC = TextEditingController();
  final _addressNC = TextEditingController();
  final _fileNC = TextEditingController();
  final _descriptionNC = TextEditingController();

  final categoryList = EduNavBarItems.items[1].label;

  String? eduName, phNum, activeHours, address, description;

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  _updateFileName(String value) {
    setState(() {
      _fileNC.text = value;
    });
  }

  Future<bool?> addEdu() async {
    bool? success;
    int? blisId = await DbManager.addToBlis(
        file!, description!, activeHours!, address!, "EDUCATION");

    if (blisId != null) {
      try {
        await DbManager.connection!.execute(
          """
        INSERT INTO EDUCATION
        VALUES (@EDUCATION_ID, @EDU_NAME, @CATEGORY, @CONTACT_NUM)
        """,
          substitutionValues: {
            "EDUCATION_ID": blisId,
            "EDU_NAME": eduName,
            "CATEGORY": dropdownValue,
            "CONTACT_NUM": phNum,
          },
        );
        success = true;
      } on PostgreSQLException {
        success = false;
        _showSnackbar("Either Education name or Phone Number is not unique");
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

  Future<bool?> modifyEdu() async {
    bool? success;

    try {
      await DbManager.connection!.execute(
        """
        UPDATE EDUCATION
        SET EDU_NAME = @EDU_NAME, CATEGORY = @CATEGORY, 
        CONTACT_NUM = @CONTACT_NUM
        WHERE EDUCATION_ID = @EDUCATION_ID
        """,
        substitutionValues: {
          "EDU_NAME": eduName,
          "CATEGORY": dropdownValue,
          "CONTACT_NUM": phNum,
          "EDUCATION_ID": widget.blisId
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
      _showSnackbar("Either Education name or Phone Number is not unique");
    }

    if (success && _fileNC.text != '') {
      try {
        await DbManager.connection!.execute(
          """
        UPDATE BLIS
        SET IMAGE = pg_read_binary_file(@IMAGE)
        WHERE BLIS_ID = @EDUCATION_ID
        """,
          substitutionValues: {"IMAGE": file!, "EDUCATION_ID": widget.blisId},
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
    _eduNC.text = widget.eduName!;
    _phNumNC.text = widget.phNum!;
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
                      const TextWidget(text: 'NEW'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 460,
                              child: BlisTextFormField(
                                controller: _eduNC,
                                text: 'Educational Centre Name',
                                validator: (String? value) {
                                  eduName = value;
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
                                  items: EduNavBarItems.items.map<DropdownMenuItem<String>>(
                                          (EduNavBarItem value) {
                                    return DropdownMenuItem<String>(
                                      value: value.label,
                                      child: Text(value.label),
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
                                maxLength: 11,
                                controller: _phNumNC,
                                text: 'Phone Number',
                                validator: (String? value) {
                                  phNum = value;
                                  return validate.reqPhoneValidation(value);
                                },
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
                                      bool? success = await addEdu();
                                      if (success!) {
                                        Navigator.of(context).pop();
                                        _showSnackbar(
                                            'Educational Centre Added Successfully.');
                                      }
                                    } else if (widget.action == 1) {
                                      bool? success = await modifyEdu();
                                      if (success!) {
                                        Navigator.of(context).pop();
                                        _showSnackbar(
                                            'Educational Centre Modified Successfully.');
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
