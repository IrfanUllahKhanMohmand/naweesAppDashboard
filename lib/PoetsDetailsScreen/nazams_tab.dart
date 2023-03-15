import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NazamsTab extends StatefulWidget {
  const NazamsTab({
    super.key,
    required this.id,
    required this.poetId,
    required this.title,
    required this.content,
  });
  final int id;
  final int poetId;
  final String title;
  final String content;

  @override
  State<NazamsTab> createState() => _NazamsTabState();
}

class _NazamsTabState extends State<NazamsTab> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> putNazam() async {
    final response =
        await http.put(Uri.parse('http://192.168.18.185:8080/nazams'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "id": widget.id,
              "title": _titleController.text.trim(),
              "content": _contentController.text.trim(),
              "poet_id": widget.poetId,
            }));
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nazam Updated')),
        );
      }
    } else {
      throw Exception('Failed to post poet');
    }
  }

  Future<void> deleteNazam() async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/nazams/${widget.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nazam Deleted')),
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
          const SizedBox(height: 16.0),
          Text(
            "Id: ${widget.id.toString()}",
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Title: ${widget.title.toString()}",
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Content: ${widget.content.toString()}",
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Poet Id: ${widget.poetId.toString()}",
            style: const TextStyle(fontSize: 16.0),
          ),
          Row(
            children: [
              MaterialButton(
                onPressed: () async {
                  _contentController.text == ''
                      ? _contentController.text = widget.content
                      : '';
                  _titleController.text == ''
                      ? _titleController.text = widget.title
                      : '';

                  await _editNazamDialog(context);
                },
                color: Colors.blue,
                child: const Text('Edit'),
              ),
              MaterialButton(
                onPressed: () async {
                  await _deleteNazamDialog(context);
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

  Future<void> _editNazamDialog(BuildContext context) async {
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
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * .2,
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: _titleController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration:
                                const InputDecoration(hintText: "Title"),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * .2,
                          ),
                          child: TextFormField(
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
                              await putNazam();
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

  Future<void> _deleteNazamDialog(BuildContext context) async {
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
                                  await deleteNazam();
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
