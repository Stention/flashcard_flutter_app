import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:io';
import 'dart:convert' show utf8;
import "database_helper.dart";
import 'quiz_find_the_word.dart';
import 'main.dart';
import 'quiz_find_translation.dart';

class DeckDetail extends StatefulWidget {
  const DeckDetail({Key? key, required this.deckId, required this.deckName})
      : super(key: key);
  final int deckId;
  final String deckName;

  @override
  _DeckDetailState createState() => _DeckDetailState();
}

class _DeckDetailState extends State<DeckDetail> {
  List<Map<String, dynamic>> _mainDeck = [];
  List<Map<String, dynamic>> _words = [];
  List<Map<String, dynamic>> _wordsWithoutSubdeck = [];

  final Map<String, List> _wordsInSubdeck = {};
  List<Map<String, dynamic>> _subDecks = [];

  bool _isLoading = true;
  int _numberOfQuestions = 10;
  String _targetLanguage = '';
  List _listOfLanguages = [];
//  List _listOfVoices = [];

  final FlutterTts tts = FlutterTts();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();

  void _refreshDecks() async {
    final deck = await DatabaseHelper.getDecks(widget.deckId);
    final data = await DatabaseHelper.getWords(widget.deckName);
    final wordsWithoutSubdeck =
        await DatabaseHelper.getWordsWithoutSubdeck(widget.deckName);
    final subDecksData = await DatabaseHelper.getSubDecks(widget.deckName);
    if (subDecksData.isNotEmpty) {
      for (int i = 0; i < subDecksData.length; i++) {
        String name = subDecksData[i]['name'];
        List subWords = await DatabaseHelper.getWordsInSubdeck(name);
        _wordsInSubdeck[name] = subWords;
      }
    }

    List<Object?> languages = await tts.getLanguages;
    //List<dynamic> voices = await tts.getVoices;
    setState(() {
      _mainDeck = deck;
      _words = data;
      _wordsWithoutSubdeck = wordsWithoutSubdeck;
      _subDecks = subDecksData;
      _isLoading = false;
      _numberOfQuestions = _mainDeck[0]["numberOfWordsToLearn"];
      if (_mainDeck[0]["targetLanguage"] == null) {
        _targetLanguage = '';
      } else {
        _targetLanguage = _mainDeck[0]["targetLanguage"];
      }
      _listOfLanguages = languages;
      // _listOfVoices = voices;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  void _showSubDeckForm(int? id) async {
    if (id != null) {
      final existingDeck =
          _subDecks.firstWhere((subdeck) => subdeck['id'] == id);
      _nameController.text = existingDeck['name'];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        builder: (_) => SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(15),
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Subdeck name',
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      child: Text(
                          id == null
                              ? 'Create new subdeck'
                              : 'Update the subdeck',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black)),
                      onPressed: () async {
                        if (id == null) {
                          await _addSubdeck();
                        }
                        if (id != null) {
                          await _updateSubdeck(id);
                        }
                        _nameController.text = '';
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ));
  }

  void _showWordForm(int? id) async {
    if (id != null) {
      final existingWord = _words[_words.indexWhere((w) => w['id'] == id)];
      _wordController.text = existingWord['word'];
      _translationController.text = existingWord['translation'];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        builder: (_) => SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(15),
                height: 470,
                child: Column(
                  children: [
                    TextField(
                      controller: _wordController,
                      decoration: const InputDecoration(
                        hintText: 'word',
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _translationController,
                      decoration: const InputDecoration(
                        hintText: 'translation',
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            child: Text(
                                id == null
                                    ? "Add a new word"
                                    : 'Update the word',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                            onPressed: () async {
                              if (id == null) {
                                await _addWord();
                              }
                              if (id != null) {
                                await _updateWord(id);
                              }
                              _wordController.text = '';
                              _translationController.text = '';
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: Text(id == null ? "Nix" : 'Delete the word',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                            onPressed: () async {
                              if (id != null) {
                                _deleteWord(_words[_words
                                    .indexWhere((w) => w['id'] == id)]['id']);
                              }
                              Navigator.of(context).pop();
                            },
                          )
                        ]),
                  ],
                ),
              ),
            ));
  }

  SpeedDial _buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 28.0),
      backgroundColor: Colors.grey[800],
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.green[800],
          onTap: () => _showSubDeckForm(null),
          label: 'add subdeck',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.black,
          onTap: () => _showWordForm(null),
          label: 'add word',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: const Icon(Icons.verified_rounded, color: Colors.white),
          backgroundColor: Colors.black,
          onTap: () {
            if (_words.length < 10) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content:
                    Text('To play games, you have to add at least 10 words!'),
              ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FindTheWord(
                          deckId: widget.deckId,
                          deckName: widget.deckName,
                          questions: _words,
                          numberOfQuestions: _numberOfQuestions)));
            }
          },
          label: 'Play "Find the word"',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: const Icon(Icons.view_comfy, color: Colors.white),
          backgroundColor: Colors.green[800],
          onTap: () {
            if (_words.length < 10) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content:
                    Text('To play games, you have to add at least 10 words!'),
              ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FindTranslation(
                          deckId: widget.deckId,
                          deckName: widget.deckName,
                          questions: _words,
                          numberOfQuestions: _numberOfQuestions)));
            }
          },
          label: 'Play "Find the translation"',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }

  _setIndicatorColour(int level) {
    if (level == 2) {
      Color color = const Color(0x00000000);
      return color;
    } else if (level > 0 && level <= 2) {
      Color color = Colors.red;
      return color;
    } else if (level > 2 && level <= 5) {
      Color color = Colors.orange;
      return color;
    } else if (level > 5 && level <= 7) {
      Color color = Colors.yellow;
      return color;
    } else if (level > 7 && level <= 10) {
      Color color = Colors.lightGreen;
      return color;
    } else if (level > 7 && level <= 10) {
      Color color = Colors.green;
      return color;
    }
  }

  _setIndicatorPercent(int level) {
    double percent = level.toDouble() / 10;
    return percent;
  }

  void _generateCsvFile() async {
    final directory = await getApplicationDocumentsDirectory();

    List<List<dynamic>> rows = [];
    List<dynamic> header = [];
    String deckName = widget.deckName;

    header.add("id");
    header.add("dictionary_name");
    header.add("sub_dictionary_name");
    header.add("word");
    header.add("translation");
    rows.add(header);
    for (int i = 0; i < _words.length; i++) {
      List<dynamic> row = [];
      row.add(_words[i]["id"]);
      row.add(_words[i]["dictionary_name"]);
      row.add(_words[i]["sub_dictionary_name"]);
      row.add(_words[i]["word"]);
      row.add(_words[i]["translation"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter(fieldDelimiter: ";").convert(rows);

    File file = File(directory.path + "/$deckName.csv");
    try {
      file.writeAsString(csv);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('File was successfully generated!'),
    ));
  }

  void _uploadCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile inputCsvFile = result.files.first;

      final input = File(inputCsvFile.path.toString()).openRead();

      final words = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(fieldDelimiter: ";"))
          .toList();

      try {
        for (List wordPair in words) {
          await DatabaseHelper.createWord(
              wordPair[0], wordPair[1], widget.deckName);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('File was successfully uploaded!'),
      ));
    }
    _refreshDecks();

    // Verifyfinal directory = await getApplicationDocumentsDirectory();
    //final inputCsvFile = File(directory.path + '/file.csv').openRead();
  }

  Future<void> _addSubdeck() async {
    await DatabaseHelper.createSubDeck(_nameController.text, widget.deckName);
    _refreshDecks();
  }

  Future<void> _updateSubdeck(int id) async {
    await DatabaseHelper.updateSubDeck(id, _nameController.text);
    _refreshDecks();
  }

  void _deleteSubDeck(int id) async {
    await DatabaseHelper.deleteSubDeck(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a subdeck!'),
    ));
    _refreshDecks();
  }

  Future<void> _addWord() async {
    await DatabaseHelper.createWord(
      _wordController.text,
      _translationController.text,
      widget.deckName,
    );
    _refreshDecks();
  }

  Future<void> _updateWord(int id) async {
    await DatabaseHelper.updateWord(
        id, _wordController.text, _translationController.text);
    _refreshDecks();
  }

  Future<void> _addWordToSubdeck(int id, String? subDeckName) async {
    await DatabaseHelper.updateWordsSubdeck(id, subDeckName);
    _refreshDecks();
  }

  Future<void> _deleteWord(int id) async {
    await DatabaseHelper.deleteWord(id);
    _refreshDecks();
  }

  Future<void> _changeNumberOfQuestions(int numberOfQuestions) async {
    await DatabaseHelper.updateDeckWordsCount(widget.deckId, numberOfQuestions);
    _refreshDecks();
  }

  Future<void> _changeTargetLanguage(String targetLanguage) async {
    await DatabaseHelper.updateDeckTargetLanguage(
        widget.deckId, targetLanguage);
    _refreshDecks();
  }

  @override
  Widget build(BuildContext context) {
    var languages = _listOfLanguages.map((item) => item as String).toList();
    tts.setLanguage(_targetLanguage);
    tts.setSpeechRate(0.5);
    return Scaffold(
        endDrawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
              child: Text("Menu",
                  style: TextStyle(
                      color: Colors.purple, fontWeight: FontWeight.bold)),
              decoration: BoxDecoration(color: Colors.black)),
          ListTile(
            title: const Text('Upload Words file'),
            onTap: () => _uploadCsvFile(),
          ),
          ListTile(
            title: const Text('Download Words file'),
            onTap: () => _generateCsvFile(),
          ),
          const ListTile(
            title: Text('How many words you want to learn?'),
          ),
          ListTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Text(_numberOfQuestions == 10 ? '10' : '10'),
                    style: ElevatedButton.styleFrom(
                      primary: _numberOfQuestions == 10 ? Colors.teal : null,
                    ),
                    onPressed: () => _changeNumberOfQuestions(10),
                  ),
                  ElevatedButton(
                    child: Text(_numberOfQuestions == 30 ? '30' : '30'),
                    style: ElevatedButton.styleFrom(
                      primary: _numberOfQuestions == 30 ? Colors.teal : null,
                    ),
                    onPressed: () {
                      _changeNumberOfQuestions(30);
                    },
                  ),
                  ElevatedButton(
                    child: Text(_numberOfQuestions == 50 ? '50' : '50'),
                    style: ElevatedButton.styleFrom(
                      primary: _numberOfQuestions == 50 ? Colors.teal : null,
                    ),
                    onPressed: () {
                      _changeNumberOfQuestions(50);
                    },
                  )
                ]),
          ),
          const ListTile(
            title: Text('Choose target language'),
          ),
          ListTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  DropdownButton<String>(
                    hint: Text(_targetLanguage.toString()),
                    items: languages.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _changeTargetLanguage(value.toString());
                    },
                  ),
                ]),
          ),
        ])),
        appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(widget.deckName,
                style: const TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePage())),
            )),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _subDecks.length,
                            itemBuilder: (BuildContext context, int index) {
                              List? wordsInSubdeck =
                                  _wordsInSubdeck[_subDecks[index]['name']];

                              return DragTarget<int>(
                                  builder: (context, data, rejectedItems) {
                                return Slidable(
                                  endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            _showSubDeckForm(
                                                _subDecks[index]['id']);
                                          },
                                          backgroundColor:
                                              const Color(0xFF7BC043),
                                          foregroundColor: Colors.white,
                                          icon: Icons.archive,
                                          label: 'Edit',
                                        ),
                                        SlidableAction(
                                          onPressed: (context) {
                                            _deleteSubDeck(
                                                _subDecks[index]['id']);
                                          },
                                          backgroundColor:
                                              const Color(0xFFFE4A49),
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ]),
                                  child: ExpansionTile(
                                    title: Text(_subDecks[index]['name']),
                                    subtitle: Text((wordsInSubdeck?.length ?? 0)
                                            .toString() +
                                        ' word(s)'),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    trailing: SizedBox(
                                      width: 100,
                                      child: Row(children: [
                                        IconButton(
                                            icon: const Icon(
                                                Icons.verified_rounded),
                                            onPressed: () {
                                              if (wordsInSubdeck!.length < 10) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'To play games, you have to add at least 10 words!'),
                                                ));
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            FindTheWord(
                                                                deckId: widget
                                                                    .deckId,
                                                                deckName: widget
                                                                    .deckName,
                                                                questions:
                                                                    wordsInSubdeck,
                                                                numberOfQuestions:
                                                                    _numberOfQuestions)));
                                              }
                                            }),
                                        IconButton(
                                            icon: const Icon(
                                                Icons.verified_user_sharp),
                                            onPressed: () {
                                              if (wordsInSubdeck!.length < 10) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'To play games, you have to add at least 10 words!'),
                                                ));
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            FindTranslation(
                                                                deckId: widget
                                                                    .deckId,
                                                                deckName:
                                                                    widget
                                                                        .deckName,
                                                                questions:
                                                                    wordsInSubdeck,
                                                                numberOfQuestions:
                                                                    _numberOfQuestions)));
                                              }
                                            }),
                                      ]),
                                    ),
                                    children: <Widget>[
                                      ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: wordsInSubdeck != null
                                              ? wordsInSubdeck.length
                                              : 0,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return LongPressDraggable(
                                              data: wordsInSubdeck![index]
                                                  ["id"],
                                              child: SizedBox(
                                                width: 350,
                                                height: 70,
                                                child: ListTile(
                                                    title: Text(
                                                        wordsInSubdeck[index]
                                                            ["word"]),
                                                    subtitle: Text(
                                                        wordsInSubdeck[index]
                                                            ["translation"]),
                                                    trailing: SizedBox(
                                                      width: 100,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          CircularPercentIndicator(
                                                            radius: 12.0,
                                                            percent: _setIndicatorPercent(
                                                                _wordsWithoutSubdeck[
                                                                        index]
                                                                    ["level"]),
                                                            progressColor:
                                                                _setIndicatorColour(
                                                                    _wordsWithoutSubdeck[
                                                                            index]
                                                                        [
                                                                        "level"]),
                                                          ),
                                                          IconButton(
                                                              icon: const Icon(Icons
                                                                  .surround_sound),
                                                              onPressed: () => tts.speak(
                                                                  wordsInSubdeck[
                                                                          index]
                                                                      [
                                                                      "word"])),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      _showWordForm(
                                                          wordsInSubdeck[index]
                                                              ['id']);
                                                    }),
                                              ),
                                              feedback: Material(
                                                  child: Container(
                                                      width: 200,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .greenAccent)),
                                                      child: ListTile(
                                                        title: Text(
                                                          wordsInSubdeck[index]
                                                              ["word"],
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ))),
                                            );
                                          })
                                    ],
                                  ),
                                );
                              }, onAccept: (data) {
                                setState(() {
                                  _addWordToSubdeck(
                                      data, _subDecks[index]['name']);
                                });
                              });
                            }),
                        DragTarget<int>(
                            builder: (context, data, rejectedItems) {
                          return SizedBox(
                            width: 400.0,
                            height: MediaQuery.of(context).size.height,
                            child: ListView.builder(
                                //  physics: const ClampingScrollPhysics(),
                                //   shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: _wordsWithoutSubdeck.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == _wordsWithoutSubdeck.length) {
                                    return const SizedBox(height: 250);
                                  } else {
                                    return LongPressDraggable(
                                        data: _wordsWithoutSubdeck[index]["id"],
                                        child: SizedBox(
                                            width: 350,
                                            height: 70,
                                            child: ListTile(
                                                title: Text(
                                                    _wordsWithoutSubdeck[index]
                                                        ["word"]),
                                                subtitle: Text(
                                                    _wordsWithoutSubdeck[index]
                                                        ["translation"]),
                                                trailing: SizedBox(
                                                  width: 100,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      CircularPercentIndicator(
                                                        radius: 12.0,
                                                        percent:
                                                            _setIndicatorPercent(
                                                                _wordsWithoutSubdeck[
                                                                        index]
                                                                    ["level"]),
                                                        progressColor:
                                                            _setIndicatorColour(
                                                                _wordsWithoutSubdeck[
                                                                        index]
                                                                    ["level"]),
                                                      ),
                                                      IconButton(
                                                          icon: const Icon(Icons
                                                              .surround_sound),
                                                          onPressed: () =>
                                                              tts.speak(
                                                                  _wordsWithoutSubdeck[
                                                                          index]
                                                                      [
                                                                      "word"])),
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  _showWordForm(
                                                      _wordsWithoutSubdeck[
                                                          index]['id']);
                                                })),
                                        feedback: Material(
                                            child: Container(
                                                width: 200,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors
                                                            .orangeAccent)),
                                                child: ListTile(
                                                  title: Text(
                                                    _wordsWithoutSubdeck[index]
                                                        ["word"],
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ))));
                                  }
                                }),
                          );
                        }, onAccept: (data) {
                          setState(() {
                            _addWordToSubdeck(data, null);
                          });
                        }),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: _buildSpeedDial());
  }
}
