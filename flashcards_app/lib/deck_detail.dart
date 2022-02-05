import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert' show utf8;
import "database_helper.dart";
import 'deck_games.dart';
import 'main.dart';
import 'painter.dart';

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
  bool _isLoading = true;
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();

  void _refreshDecks() async {
    final data = await DatabaseHelper.getWords(widget.deckName);
    setState(() {
      _words = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  void _showForm() async {
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
                      decoration: const InputDecoration(hintText: 'word'),
                    ),
                    TextField(
                      controller: _translationController,
                      decoration:
                          const InputDecoration(hintText: 'translation'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      child: const Text("Add a new word"),
                      onPressed: () async {
                        await _addWord();
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

  Future<void> _addWord() async {
    await DatabaseHelper.createWord(widget.deckId, widget.deckName,
        _wordController.text, _translationController.text);
    _refreshDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(widget.deckName,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
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
            : Container(
                alignment: Alignment.topCenter,
                child: DataTable(
                    showCheckboxColumn: false,
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Center(
                            child: Text("Slovíčko",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontStyle: FontStyle.italic))),
                      ),
                      DataColumn(
                        label: Center(
                            child: Text("Překlad",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontStyle: FontStyle.italic))),
                      ),
                      DataColumn(
                        label: Center(
                            child: Text("Úroveň",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontStyle: FontStyle.italic))),
                      ),
                    ],
                    rows: _words
                        .map((word) => DataRow(
                            color: MaterialStateColor.resolveWith(
                                (states) => Colors.grey.shade100),
                            cells: [
                              DataCell(Text(word["word"],
                                  textAlign: TextAlign.center)),
                              DataCell(Text(word["translation"],
                                  textAlign: TextAlign.center)),
                              DataCell(Text(word["level"].toString(),
                                  textAlign: TextAlign.center)),
                            ],
                            onSelectChanged: (newValue) {
                              //
                            }))
                        .toList()),
              ),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.add),
            onPressed: () => _showForm(),
          ),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GamesDetail(
                          deckId: widget.deckId,
                          deckName: widget.deckName,
                        )),
              );
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.upload),
            onPressed: () => _uploadCsvFile(),
          ),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.download),
            onPressed: () => _generateCsvFile(),
          ),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPainter()),
              );
            },
          ),
        ]));
  }
}
