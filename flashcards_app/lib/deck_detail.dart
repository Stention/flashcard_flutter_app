import 'package:flashcards_app/quiz_find_the_word.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:io';
import 'dart:convert' show utf8;
import "database_helper.dart";
import 'main.dart';
import 'quiz_find_the_word.dart';
import 'quiz_find_translation.dart';

class DeckDetail extends StatefulWidget {
  const DeckDetail({Key? key, required this.deckId, required this.deckName})
      : super(key: key);
  final String deckId;
  final String deckName;

  @override
  _DeckDetailState createState() => _DeckDetailState();
}

class _DeckDetailState extends State<DeckDetail> {
  List<Map<String, dynamic>> _words = [];
  List<Map<String, dynamic>> _subDecks = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  final TextEditingController _numberOfQuestions = TextEditingController();

  void _refreshDecks() async {
    final data = await DatabaseHelper.getWords(widget.deckName);
    final subDecksData = await DatabaseHelper.getSubDictionaries();
    setState(() {
      _words = data;
      _subDecks = subDecksData;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  void _showSubDeckForm() async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        builder: (_) => Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'name of a subdeck',
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
                      child: const Text("Add a new subdeck",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black)),
                      onPressed: () async {
                        await _addSubdeck();
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
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        builder: (_) => Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _wordController,
                      decoration: InputDecoration(
                        hintText: id == null ? 'word' : _words[id]['word'],
                        focusedBorder: const OutlineInputBorder(
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
                      decoration: InputDecoration(
                        hintText: id == null
                            ? 'translation'
                            : _words[id]['translation'],
                        focusedBorder: const OutlineInputBorder(
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
                          id == null ? "Add a new word" : 'Update the word',
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
                  ],
                ),
              ),
            ));
  }

  SpeedDial _buildWordsSpeedDial() {
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
          onTap: () => _showSubDeckForm(),
          label: 'subdeck',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.black,
          onTap: () => _showWordForm(null),
          label: 'word',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }

  SpeedDial _buildMenuSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 28.0),
      backgroundColor: Colors.grey[800],
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.verified_rounded, color: Colors.white),
          backgroundColor: Colors.black,
          onTap: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                        title: const Text(
                            "How many words do you wanna play with?"),
                        content: TextField(
                          controller: _numberOfQuestions,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        actions: [
                          TextButton(
                              child: const Text("Play"),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FindTheWord(
                                            deckId: widget.deckId,
                                            deckName: widget.deckName,
                                            numberOfQuestions:
                                                _numberOfQuestions.text)));
                              }),
                        ]));
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
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                        title: const Text(
                            "How many words do you wanna play with?"),
                        content: TextField(
                          controller: _numberOfQuestions,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        actions: [
                          TextButton(
                              child: const Text("Play"),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FindTranslation(
                                            deckId: widget.deckId,
                                            deckName: widget.deckName,
                                            numberOfQuestions:
                                                _numberOfQuestions.text)));
                              }),
                        ]));
          },
          label: 'Play "Find the translation"',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: const Icon(Icons.upload, color: Colors.white),
          backgroundColor: Colors.black,
          onTap: () => _uploadCsvFile(),
          label: 'upload file',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: const Icon(Icons.download, color: Colors.white),
          backgroundColor: Colors.black,
          onTap: () => _generateCsvFile(),
          label: 'download',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }

  void _generateCsvFile() async {
    final directory = await getApplicationDocumentsDirectory();
    List<List<dynamic>> rows = [];
    List<dynamic> header = [];
    String deckName = widget.deckName;

    header.add("id");
    header.add("dictionary_id");
    header.add("dictionary_name");
    header.add("sub_dictionary_name");
    header.add("word");
    header.add("translation");
    rows.add(header);
    for (int i = 0; i < _words.length; i++) {
      List<dynamic> row = [];
      row.add(_words[i]["id"]);
      row.add(_words[i]["dictionary_id"]);
      row.add(_words[i]["dictionary_name"]);
      row.add(_words[i]["sub_dictionary_name"]);
      row.add(_words[i]["word"]);
      row.add(_words[i]["translation"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter(fieldDelimiter: ";").convert(rows);

    File file = File(directory.path + "/$deckName.csv");
    file.writeAsString(csv);
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

      for (List wordPair in words) {
        await DatabaseHelper.createWord(
            widget.deckId, widget.deckName, wordPair[0], wordPair[1]);
      }
    }
    _refreshDecks();

    //final directory = await getApplicationDocumentsDirectory();
    //final inputCsvFile = File(directory.path + '/file.csv').openRead();
  }

  Future<void> _addSubdeck() async {
    await DatabaseHelper.createSubDictionary(
        _nameController.text, int.parse(widget.deckId), widget.deckName);
    _refreshDecks();
  }

  void _deleteSubDeck(int id) async {
    await DatabaseHelper.deleteSubDictionary(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a subdeck!'),
    ));
    _refreshDecks();
  }

  Future<void> _addWord() async {
    await DatabaseHelper.createWord(
      _wordController.text,
      _translationController.text,
      widget.deckId,
      widget.deckName,
    );
    _refreshDecks();
  }

  Future<void> _updateWord(int id) async {
    await DatabaseHelper.updateWord(
        id, _wordController.text, _translationController.text);
    _refreshDecks();
  }

  Future<void> _deleteWord(int id) async {
    await DatabaseHelper.deleteWord(id);
    _refreshDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.deckName,
              style: const TextStyle(
                  color: Colors.purple, fontWeight: FontWeight.bold)),
          leading: IconButton(
            color: Colors.black,
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
                            return ExpansionTile(
                              title: Text(_subDecks[index]['name']),
                              subtitle: const Text('number of words'),
                              controlAffinity: ListTileControlAffinity.leading,
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteSubDeck(_subDecks[index]['id'])),
                              children: const <Widget>[
                                ListTile(title: Text('word')),
                              ],
                            );
                          }),
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _words.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                leading: Text(_words[index]["word"] +
                                    '   --->   ' +
                                    _words[index]["translation"] +
                                    '   ( ' +
                                    _words[index]["level"].toString() +
                                    ' )'),
                                trailing: SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _showWordForm(index)),
                                      IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              _deleteWord(_words[index]['id'])),
                                    ],
                                  ),
                                ),
                                onTap: () {});
                          }),
                    ],
                  ),
                ),
              ],
            ),
      //  floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(children: [_buildMenuSpeedDial(), _buildWordsSpeedDial()])
          ]),
    );
  }
}
