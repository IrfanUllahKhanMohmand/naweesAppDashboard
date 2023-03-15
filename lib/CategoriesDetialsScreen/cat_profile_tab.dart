import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

class CatProfileTab extends StatefulWidget {
  const CatProfileTab(
      {super.key,
      required this.name,
      required this.details,
      required this.poetId,
      required this.pic});
  final int poetId;
  final String name;
  final String details;
  final String pic;

  @override
  State<CatProfileTab> createState() => _CatProfileTabState();
}

class _CatProfileTabState extends State<CatProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
        await dio.put("http://192.168.18.185:8080/category", data: formData);
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category Updated')),
        );
      }
    } else {
      throw Exception('Failed to update category');
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
