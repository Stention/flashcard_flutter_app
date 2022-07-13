import 'dart:io';
import 'dart:convert' show utf8;
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashcards_app/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CsvManager {
  void uploadCsvFile(String deckName, dynamic context,
      {required refreshDeck}) async {
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
          await DatabaseHelper.createWord(wordPair[0], wordPair[1], deckName);
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
    refreshDeck();

    // Verifyfinal directory = await getApplicationDocumentsDirectory();
    //final inputCsvFile = File(directory.path + '/file.csv').openRead();
  }

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
}
