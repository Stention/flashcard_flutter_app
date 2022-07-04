import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void generateCsvFile(String deckName, List words, dynamic context) async {
  final directory = await getApplicationDocumentsDirectory();

  List<List<dynamic>> rows = [];
  List<dynamic> header = [];

  header.add("id");
  header.add("dictionary_name");
  header.add("sub_dictionary_name");
  header.add("word");
  header.add("translation");
  rows.add(header);
  for (int i = 0; i < words.length; i++) {
    List<dynamic> row = [];
    row.add(words[i]["id"]);
    row.add(words[i]["dictionary_name"]);
    row.add(words[i]["sub_dictionary_name"]);
    row.add(words[i]["word"]);
    row.add(words[i]["translation"]);
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
