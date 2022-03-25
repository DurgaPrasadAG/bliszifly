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

class HospitalFormScreen extends StatefulWidget {
  const HospitalFormScreen({Key? key, this.hospName, this.doctorName,
    this.specialization, this.phNum, this.activeHours, this.address,
    this.description, this.image, this.action, this.title, this.heading, this.blisId}) : super(key: key);
  static const id = '/hospital_form_screen';

  final int? action;
  final String? blisId;
  final String? hospName,
      doctorName,
      specialization,
      phNum,
      activeHours,
      address,
      description;

  final Uint8List? image;
  final String? title, heading;

  @override
  _HospitalFormScreenState createState() => _HospitalFormScreenState();
}

class _HospitalFormScreenState extends State<HospitalFormScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final validate = PostValidation();

  final _hospitalNC = TextEditingController();

  final _fileNC = TextEditingController();
  final _doctorNC = TextEditingController();
  final _specializationNC = TextEditingController();
  final _phNumNC = TextEditingController();
  final _activeNC = TextEditingController();
  final _addressNC = TextEditingController();
  final _descriptionNC = TextEditingController();

  FilePickerResult? result;
  String? file;
  String? fileName;

  String? hospName,
      doctorName,
      specialization,
      phNum,
      activeHours,
      address,
      description;

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  _updateFileName(String value) {
    setState(() {
      _fileNC.text = value;
    });
  }

  Future<bool?> addHospital() async {
    bool? success;
    int? blisId =
    await DbManager.addToBlis(file!, description!, activeHours!, address!, "HOSPITAL");

    if (blisId != null) {
      try {
        await DbManager.connection!.execute(
          """
        INSERT INTO HOSPITAL
        VALUES (@HOSPITAL_ID, @HOSPITAL_NAME, @DOCTOR_NAME, @SPECIALIZATION, @CONTACT_NUM)
        """,
          substitutionValues: {
            "HOSPITAL_ID": blisId,
            "HOSPITAL_NAME": hospName,
            "DOCTOR_NAME": doctorName,
            "SPECIALIZATION": specialization,
            "CONTACT_NUM": phNum,
          },
        );
        success = true;
      } on PostgreSQLException {
        success = false;
        _showSnackbar("Either Hospital name or Phone Number is not unique");
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

  Future<bool?> modifyHospital() async {
    bool? success;

      try {
        await DbManager.connection!.execute(
          """
        UPDATE HOSPITAL
        SET HOSPITAL_NAME = @HOSPITAL_NAME, DOCTOR_NAME = @DOCTOR_NAME, 
        SPECIALIZATION = @SPECIALIZATION, CONTACT_NUM = @CONTACT_NUM
        WHERE HOSPITAL_ID = @HOSPITAL_ID
        """,
          substitutionValues: {
            "HOSPITAL_NAME": hospName,
            "DOCTOR_NAME": doctorName,
            "SPECIALIZATION": specialization,
            "CONTACT_NUM": phNum,
            "HOSPITAL_ID": widget.blisId
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
        _showSnackbar("Either Hospital name or Phone Number is not unique");
      }

      if (success && _fileNC.text != '') {
        try {
          await DbManager.connection!.execute(
            """
        UPDATE BLIS
        SET IMAGE = pg_read_binary_file(@IMAGE)
        WHERE BLIS_ID = @HOSPITAL_ID
        """,
            substitutionValues: {
              "IMAGE": file!,
              "HOSPITAL_ID": widget.blisId
            },
          );
          success = true;
        } on PostgreSQLException {
          success = false;
          _showSnackbar("This image is not supported.");
        }
      }

    if(success) {
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
    _hospitalNC.text = widget.hospName!;
    _doctorNC.text = widget.doctorName!;
    _specializationNC.text = widget.specialization!;
    _phNumNC.text = widget.phNum!;
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
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('${widget.title}'),
        ),
        body: Builder(builder: (context) {
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
                      TextWidget(text: '${widget.heading}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 460,
                              child: BlisTextFormField(
                                controller: _hospitalNC,
                                text: 'Hospital Name',
                                validator: (String? value) {
                                  hospName = value;
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
                              width: 225,
                              child: BlisTextFormField(
                                controller: _doctorNC,
                                text: 'Doctor Name',
                                validator: (String? value) {
                                  doctorName = value;
                                  return null;
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
                                controller: _specializationNC,
                                text: 'Specialization',
                                validator: (String? value) {
                                  specialization = value;
                                  return null;
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
                              width: 225,
                              child: BlisTextFormField(
                                controller: _phNumNC,
                                text: 'Phone Number',
                                validator: (String? value) {
                                  phNum = value;
                                  return validate.reqPhoneValidation(value);
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
                                      withData: true
                                  );
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
                                      bool? success = await addHospital();
                                      if (success!) {
                                        Navigator.of(context).pop();
                                        _showSnackbar('Hospital Added Successfully.');
                                      }
                                    } else if (widget.action == 1) {
                                      bool? success = await modifyHospital();
                                      if (success!) {
                                        Navigator.of(context).pop();
                                        _showSnackbar('Hospital Modified Successfully.');
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
        }),
    );
  }
}
