import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:admin_panel/PoetsDetailsScreen/poet_detail.dart';
import 'package:admin_panel/models/poet.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PoetList extends StatefulWidget {
  const PoetList({super.key});

  @override
  State<PoetList> createState() => _PoetListState();
}

class _PoetListState extends State<PoetList> {
  List<Poet> poets = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _deathDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPoets();
  }

  File? pic;
  final _picker = ImagePicker();
  Future getImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      pic = File(pickedFile.path);
      setState(() {});
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('no image selected')),
        );
      }
    }
  }

  List<int>? bytes;
  dynamic name;
  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      bytes = result.files.single.bytes!.cast();

      name = result.files.single.name;
    }
  }

  Future<void> putPoet(List<int> bytes, String name) async {
    var dio = Dio();

    String extension = name.split(".").last;

    var formData = FormData.fromMap({
      "name": _nameController.text.trim(),
      "father_name": _fatherNameController.text.trim(),
      "birth_date": _birthDateController.text.trim(),
      "death_date": _deathDateController.text.trim(),
      "description": _descriptionController.text.trim(),
      "pic": MultipartFile.fromBytes(
        bytes,
        filename: name,
        contentType: MediaType("File", extension),
      ),
    });

    final response =
        await dio.post("http://192.168.18.185:8080/poets", data: formData);
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

  Future<void> fetchPoets() async {
    final response =
        await http.get(Uri.parse('http://192.168.18.185:8080/poets'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        poets = data.map((json) => Poet.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to fetch poets');
    }
  }

  Future<void> deletePoet(int id) async {
    final response =
        await http.delete(Uri.parse('http://192.168.18.185:8080/poets/$id'));
    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poet Deleted')),
        );
      }
    } else {
      throw Exception('Failed to delete poets');
    }
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

  void refresh() {
    fetchPoets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Poet List'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () {
                      refresh();
                    },
                    child: const Icon(Icons.refresh)),
                const SizedBox(width: 10),
                const SizedBox(width: 10),
                const SizedBox(width: 10),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            ListTile(
                title: const Text('Add New Poet'),
                onTap: () async {
                  await _displayTextInputDialog(context);
                }),
            SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: ListView.builder(
                  itemCount: poets.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        title: Text(poets[index].name),
                        subtitle: Text(poets[index].description),
                        onLongPress: () async {
                          await _deleteDialog(context, poets[index].id);
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PoetDetail(poetId: poets[index].id),
                            ),
                          );
                        });
                  }),
            ),
          ],
        ));
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
                                // await postPoet();
                                await putPoet(bytes!, name);
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

  Future<void> _deleteDialog(BuildContext context, int id) async {
    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: formKey,
            child: Center(
              child: Material(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .2,
                  width: MediaQuery.of(context).size.width * .2,
                  child: Padding(
                    padding: const EdgeInsets.all(38.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Do you want to delete it?')
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              child: const Text('Yes'),
                              onPressed: () async {
                                await deletePoet(id);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            TextButton(
                              child: const Text('No'),
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
