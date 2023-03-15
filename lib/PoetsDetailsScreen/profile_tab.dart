import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab(
      {super.key,
      required this.name,
      required this.fatherName,
      required this.birthDate,
      required this.deathDate,
      required this.details,
      required this.poetId,
      required this.pic});
  final int poetId;
  final String name;
  final String fatherName;
  final String birthDate;
  final String deathDate;
  final String details;
  final String pic;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _deathDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  DateTime? _selectedBirthDate;
  DateTime? _selectedDeathDate;

  _selectBirthDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1700),
      lastDate: DateTime(2040),
    );

    if (newSelectedDate != null) {
      _selectedBirthDate = newSelectedDate;
      _birthDateController
        ..text = DateFormat('dd-MM-yyyy').format(_selectedBirthDate!)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _birthDateController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  _selectDeathDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeathDate ?? DateTime.now(),
      firstDate: DateTime(1700),
      lastDate: DateTime(2040),
    );

    if (newSelectedDate != null) {
      _selectedDeathDate = newSelectedDate;
      _deathDateController
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDeathDate!)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _deathDateController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  List<int>? bytes;
  String? name;
  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      bytes = result.files.single.bytes!.cast();
      name = result.files.single.name;
    }
  }

  Future<void> putPoet(List<int>? bytes, String? name) async {
    var dio = Dio();

    String extension = name != null ? name.split(".").last : '';

    var formData = FormData.fromMap({
      "id": widget.poetId,
      "name": _nameController.text.trim(),
      "father_name": _fatherNameController.text.trim(),
      "birth_date": _birthDateController.text.trim(),
      "death_date": _deathDateController.text.trim(),
      "description": _descriptionController.text.trim(),
      "pic": bytes != null
          ? MultipartFile.fromBytes(
              bytes,
              filename: name,
              contentType: MediaType("File", extension),
            )
          : widget.pic,
    });

    final response =
        await dio.put("http://192.168.18.185:8080/poets", data: formData);
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poet Updated')),
        );
      }
    } else {
      throw Exception('Failed to post poet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Text(
            widget.fatherName,
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.birthDate,
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.deathDate,
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          Text(
            widget.details,
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          widget.pic != ''
              ? CircleAvatar(
                  radius: 50.0,
                  backgroundImage: NetworkImage(widget.pic),
                  backgroundColor: Colors.transparent,
                )
              : Container(),
          MaterialButton(
            onPressed: () async {
              _nameController.text == ''
                  ? _nameController.text = widget.name
                  : '';
              _fatherNameController.text == ''
                  ? _fatherNameController.text = widget.fatherName
                  : '';
              _birthDateController.text == ''
                  ? _birthDateController.text = widget.birthDate
                  : '';
              _deathDateController.text == ''
                  ? _deathDateController.text = widget.deathDate
                  : '';
              _descriptionController.text == ''
                  ? _descriptionController.text = widget.details
                  : '';
              await _displayTextInputDialog(context);
            },
            color: Colors.blue,
            child: const Text('Edit'),
          )
        ],
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Form(
              key: formKey,
              child: Center(
                child: Material(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .8,
                    width: MediaQuery.of(context).size.width * .5,
                    child: Padding(
                      padding: const EdgeInsets.all(38.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50.0,
                            backgroundImage: bytes != null
                                ? MemoryImage(Uint8List.fromList(bytes!))
                                : bytes == null && widget.pic.isNotEmpty
                                    ? NetworkImage(widget.pic)
                                    : const AssetImage('images/user.png')
                                        as ImageProvider,
                            backgroundColor: Colors.transparent,
                          ),
                          MaterialButton(
                            onPressed: () async {
                              // await getImage();
                              await pickFile();
                              setState(() {});
                            },
                            child: const Text('Pick'),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: _nameController,
                            decoration: const InputDecoration(hintText: "name"),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: _fatherNameController,
                            decoration:
                                const InputDecoration(hintText: "fatherName"),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onTap: () {
                              _selectBirthDate(context);
                            },
                            controller: _birthDateController,
                            decoration:
                                const InputDecoration(hintText: "birthDate"),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onTap: () {
                              _selectDeathDate(context);
                            },
                            controller: _deathDateController,
                            decoration:
                                const InputDecoration(hintText: "deathDate"),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: _descriptionController,
                            decoration:
                                const InputDecoration(hintText: "description"),
                          ),
                          TextButton(
                            child: const Text('CANCEL'),
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                          ),
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                await putPoet(bytes, name);
                                setState(() {
                                  Navigator.pop(context);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
