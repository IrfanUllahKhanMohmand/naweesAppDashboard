import 'package:admin_panel/CategoriesDetialsScreen/cat_ghazals_tab.dart';
import 'package:admin_panel/CategoriesDetialsScreen/cat_nazams_tab.dart';
import 'package:admin_panel/CategoriesDetialsScreen/cat_profile_tab.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryDetail extends StatefulWidget {
  final int catId;
  const CategoryDetail({Key? key, required this.catId}) : super(key: key);

  @override
  State<CategoryDetail> createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  Map catData = {};
  List catNazamsData = [];
  List catGhazalsData = [];
  List catShersData = [];
  final TextEditingController _nazamContentController = TextEditingController();
  final TextEditingController _nazamtitleController = TextEditingController();
  final TextEditingController _ghazalContentController =
      TextEditingController();
  final TextEditingController _sherContentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getCatData();
    getCatNazamsData();
    getCatGhazalsData();
    getCatShersData();
  }

  void refresh() {
    getCatData();
    getCatNazamsData();
    getCatGhazalsData();
    getCatShersData();
    setState(() {});
  }

  Future<void> getCatData() async {
    var response = await http.get(
      Uri.parse('http://192.168.18.185:8080/category/${widget.catId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        catData = jsonDecode(response.body);
      });
    }
  }

  Future<void> getCatNazamsData() async {
    var response = await http.get(
      Uri.parse(
          'http://192.168.18.185:8080/nazamsByCategory?cat_id=${widget.catId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        catNazamsData = jsonDecode(response.body);
      });
    }
  }

  Future<void> getCatGhazalsData() async {
    var response = await http.get(
      Uri.parse(
          'http://192.168.18.185:8080/ghazalsByCategory?cat_id=${widget.catId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        catGhazalsData = jsonDecode(response.body);
      });
    }
  }

  Future<void> getCatShersData() async {
    var response = await http.get(
      Uri.parse(
          'http://192.168.18.185:8080/shersByCategory?cat_id=${widget.catId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        catShersData = jsonDecode(response.body);
      });
    }
  }

  Future<void> addNazam() async {
    final response =
        await http.post(Uri.parse('http://192.168.18.185:8080/catnazams'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "title": _nazamtitleController.text.trim(),
              "content": _nazamContentController.text.trim(),
              "cat_id": widget.catId,
            }));
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category Nazam Added')),
        );
      }
    } else {
      throw Exception('Failed to post Category Nazam');
    }
  }

  Future<void> addGhazal() async {
    final response =
        await http.post(Uri.parse('http://192.168.18.185:8080/catghazals'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "content": _ghazalContentController.text.trim(),
              "cat_id": widget.catId,
            }));
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category Ghazal Added')),
        );
      }
    } else {
      throw Exception('Failed to post Category Ghazal');
    }
  }

  Future<void> addSher() async {
    final response =
        await http.post(Uri.parse('http://192.168.18.185:8080/catshers'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "content": _ghazalContentController.text.trim(),
              "cat_id": widget.catId,
            }));
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category Sher Added')),
        );
      }
    } else {
      throw Exception('Failed to post Category Sher');
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Details'),
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
      body: [
        CatProfileTab(
            name: catData['name'] ?? '',
            details: catData['description'] ?? '',
            pic: catData['pic'] ?? '',
            poetId: widget.catId),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Nazams:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            MaterialButton(
              onPressed: () async {
                await _addNazamDialog(context);
                _nazamContentController.clear;
                _nazamtitleController.clear();
              },
              color: Colors.blue,
              child: const Text('Add'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .6,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: catNazamsData.length,
                itemBuilder: (context, index) {
                  return CatNazamsTab(
                    id: catNazamsData[index]['id'],
                    catId: catNazamsData[index]['cat_id'],
                    title: catNazamsData[index]['title'],
                    content: catNazamsData[index]['content'],
                  );
                },
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Ghazals:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            MaterialButton(
              onPressed: () async {
                await _addGhazalDialog(context);
              },
              color: Colors.blue,
              child: const Text('Add'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .6,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: catGhazalsData.length,
                itemBuilder: (context, index) {
                  return CatGhazalsTab(
                    id: catGhazalsData[index]['id'],
                    catId: catGhazalsData[index]['cat_id'],
                    content: catGhazalsData[index]['content'],
                  );
                },
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Shers:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            MaterialButton(
              onPressed: () async {
                await _addSherDialog(context);
              },
              color: Colors.blue,
              child: const Text('Add'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .6,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: catShersData.length,
                itemBuilder: (context, index) {
                  return CatGhazalsTab(
                    id: catShersData[index]['id'],
                    catId: catShersData[index]['cat_id'],
                    content: catShersData[index]['content'],
                  );
                },
              ),
            ),
          ],
        ),
      ].elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Text('Profile'), label: ''),
            BottomNavigationBarItem(icon: Text('Nazams'), label: ''),
            BottomNavigationBarItem(icon: Text('Ghazals'), label: ''),
            BottomNavigationBarItem(icon: Text('Shers'), label: ''),
          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          iconSize: 40,
          onTap: _onItemTapped,
          elevation: 5),
    );
  }

  Future<void> _addNazamDialog(BuildContext context) async {
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
                            controller: _nazamtitleController,
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
                            controller: _nazamContentController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration:
                                const InputDecoration(hintText: "Content"),
                          ),
                        ),
                        TextButton(
                          child: const Text('CANCEL'),
                          onPressed: () {
                            _nazamContentController.clear;
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await addNazam();
                              refresh();

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

  Future<void> _addGhazalDialog(BuildContext context) async {
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
                            controller: _ghazalContentController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration:
                                const InputDecoration(hintText: "Content"),
                          ),
                        ),
                        TextButton(
                          child: const Text('CANCEL'),
                          onPressed: () {
                            _ghazalContentController.clear;
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await addGhazal();
                              refresh();
                              _ghazalContentController.clear;
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

  Future<void> _addSherDialog(BuildContext context) async {
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
                            controller: _sherContentController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration:
                                const InputDecoration(hintText: "Content"),
                          ),
                        ),
                        TextButton(
                          child: const Text('CANCEL'),
                          onPressed: () {
                            _ghazalContentController.clear;
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await addSher();
                              refresh();
                              _ghazalContentController.clear;
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
}
