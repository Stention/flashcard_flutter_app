import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

void generateCsvFile(String deckName, List words) async {
  final directory = await getApplicationDocumentsDirectory();
  List<List<dynamic>> rows = [];
  List<dynamic> header = [];
  List _words = words;

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
