import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CatShersTab extends StatefulWidget {
  const CatShersTab({
    super.key,
    required this.id,
    required this.catId,
    required this.content,
  });
  final int id;
  final int catId;
  final String content;

  @override
  State<CatShersTab> createState() => _CatShersTabState();
}

class _CatShersTabState extends State<CatShersTab> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> putSher() async {
    final response =
        await http.put(Uri.parse('http://192.168.18.185:8080/catshers'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "id": widget.id,
              "content": _contentController.text.trim(),
              "cat_id": widget.catId,
            }));
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category Sher Updated')),
        );
      }
    } else {
      throw Exception('Failed to update category sher');
    }
  }

  Future<void> deleteSher() async {
    final response = await http.delete(
      Uri.parse('http://192.168.18.185:8080/catshers/${widget.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category Sher Deleted')),
        );
      }
    } else {
      throw Exception('Failed to delete category sher');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Text(
            "Id: ${widget.id.toString()}",
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Content: ${widget.content.toString()}",
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Category Id: ${widget.catId.toString()}",
            style: const TextStyle(fontSize: 16.0),
          ),
          Row(
            children: [
              MaterialButton(
                onPressed: () async {
                  _contentController.text == ''
                      ? _contentController.text = widget.content
                      : '';

                  await _editSherDialog(context);
                },
                color: Colors.blue,
                child: const Text('Edit'),
              ),
              MaterialButton(
                onPressed: () async {
                  await _deleteSherDialog(context);
                },
                color: Colors.blue,
                child: const Text('Delete'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _editSherDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: formKey,
            child: Center(
              child: Material(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .3,
                  child: Padding(
                    padding: const EdgeInsets.all(38.0),
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          controller: _contentController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration:
                              const InputDecoration(hintText: "Content"),
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
                              await putSher();
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
  }

  Future<void> _deleteSherDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: formKey,
            child: Center(
              child: Material(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width * .2,
                  child: Padding(
                    padding: const EdgeInsets.all(38.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Do you want to delete it?'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              child: const Text('Yes'),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  await deleteSher();
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                }
                              },
                            ),
                            TextButton(
                              child: const Text('CANCEL'),
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
