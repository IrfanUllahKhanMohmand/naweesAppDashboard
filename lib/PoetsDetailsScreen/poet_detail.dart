import 'package:admin_panel/PoetsDetailsScreen/ghazals_tab.dart';
import 'package:admin_panel/PoetsDetailsScreen/nazams_tab.dart';

import 'profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PoetDetail extends StatefulWidget {
  final int poetId;
  const PoetDetail({Key? key, required this.poetId}) : super(key: key);

  @override
  State<PoetDetail> createState() => _PoetDetailState();
}

class _PoetDetailState extends State<PoetDetail> {
  Map poetData = {};
  List nazamsData = [];
  List ghazalsData = [];
  List shersData = [];
  final TextEditingController _nazamContentController = TextEditingController();
  final TextEditingController _nazamtitleController = TextEditingController();
  final TextEditingController _ghazalContentController =
      TextEditingController();
  final TextEditingController _sherContentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getPoetData();
    getNazamsData();
    getGhazalsData();
    getShersData();
  }

  void refresh() {
    getPoetData();
    getNazamsData();
    getGhazalsData();
    getShersData();
    setState(() {});
  }

  Future<void> getPoetData() async {
    var response = await http.get(
      Uri.parse('http://192.168.18.185:8080/poets/${widget.poetId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        poetData = jsonDecode(response.body);
      });
    }
  }

  Future<void> getNazamsData() async {
    var response = await http.get(
      Uri.parse(
          'http://192.168.18.185:8080/nazamsByPoet?poet_id=${widget.poetId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        nazamsData = jsonDecode(response.body);
      });
    }
  }

  Future<void> getGhazalsData() async {
    var response = await http.get(
      Uri.parse(
          'http://192.168.18.185:8080/ghazalsByPoet?poet_id=${widget.poetId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        ghazalsData = jsonDecode(response.body);
      });
    }
  }

  Future<void> getShersData() async {
    var response = await http.get(
      Uri.parse(
          'http://192.168.18.185:8080/shersByPoet?poet_id=${widget.poetId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        shersData = jsonDecode(response.body);
      });
    }
  }

  Future<void> addNazam() async {
    final response =
        await http.post(Uri.parse('http://192.168.18.185:8080/nazams'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "title": _nazamtitleController.text.trim(),
              "content": _nazamContentController.text.trim(),
              "poet_id": widget.poetId,
            }));
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nazam Added')),
        );
      }
    } else {
      throw Exception('Failed to post Nazam');
    }
  }

  Future<void> addGhazal() async {
    final response =
        await http.post(Uri.parse('http://192.168.18.185:8080/ghazals'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "content": _ghazalContentController.text.trim(),
              "poet_id": widget.poetId,
            }));
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ghazal Added')),
        );
      }
    } else {
      throw Exception('Failed to post Ghazal');
    }
  }

  Future<void> addSher() async {
    final response =
        await http.post(Uri.parse('http://192.168.18.185:8080/shers'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "content": _ghazalContentController.text.trim(),
              "poet_id": widget.poetId,
            }));
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sher Added')),
        );
      }
    } else {
      throw Exception('Failed to post Sher');
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
        title: const Text('Poet Detail'),
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
        ProfileTab(
            name: poetData['name'] ?? '',
            fatherName: poetData['father_name'] ?? '',
            birthDate: poetData['birth_date'] ?? '',
            deathDate: poetData['death_date'] ?? '',
            details: poetData['description'] ?? '',
            pic: poetData['pic'] ?? '',
            poetId: widget.poetId),
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
                itemCount: nazamsData.length,
                itemBuilder: (context, index) {
                  return NazamsTab(
                    id: nazamsData[index]['id'],
                    poetId: nazamsData[index]['poet_id'],
                    title: nazamsData[index]['title'],
                    content: nazamsData[index]['content'],
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
                itemCount: ghazalsData.length,
                itemBuilder: (context, index) {
                  return GhazalsTab(
                    id: ghazalsData[index]['id'],
                    poetId: ghazalsData[index]['poet_id'],
                    content: ghazalsData[index]['content'],
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
                itemCount: shersData.length,
                itemBuilder: (context, index) {
                  return GhazalsTab(
                    id: shersData[index]['id'],
                    poetId: shersData[index]['poet_id'],
                    content: shersData[index]['content'],
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
