import 'dart:io';
import 'dart:convert' show utf8;
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashcards_app/database_helper.dart';
import 'package:flutter/material.dart';

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
