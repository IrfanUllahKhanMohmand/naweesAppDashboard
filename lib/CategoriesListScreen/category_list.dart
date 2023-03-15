import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:admin_panel/CategoriesDetialsScreen/category_details.dart';
import 'package:admin_panel/models/category.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Category> categories = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
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

  Future<void> putCategory(List<int> bytes, String name) async {
    var dio = Dio();

    String extension = name.split(".").last;

    var formData = FormData.fromMap({
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "pic": MultipartFile.fromBytes(
        bytes,
        filename: name,
        contentType: MediaType("File", extension),
      ),
    });

    final response =
        await dio.post("http://192.168.18.185:8080/category", data: formData);
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category Added')),
        );
      }
    } else {
      throw Exception('Failed to post category');
    }
  }

  Future<void> fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://192.168.18.185:8080/category'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        categories = data.map((json) => Category.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to fetch poets');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response =
        await http.delete(Uri.parse('http://192.168.18.185:8080/category/$id'));
    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category Deleted')),
        );
      }
    } else {
      throw Exception('Failed to delete Category');
    }
  }

  void refresh() {
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Category List'),
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
                title: const Text('Add New Category'),
                onTap: () async {
                  await _displayTextInputDialog(context);
                }),
            SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        title: Text(categories[index].name),
                        subtitle: Text(categories[index].description),
                        onLongPress: () async {
                          await _deleteDialog(context, categories[index].id);
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategoryDetail(catId: categories[index].id),
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
                                await putCategory(bytes!, name);
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
                                await deleteCategory(id);
                                if (!mounted) return;
                                Navigator.pop(context);
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
