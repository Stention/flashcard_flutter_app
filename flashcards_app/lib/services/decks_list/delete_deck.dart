import 'package:flutter/material.dart';
import 'package:flashcards_app/database_helper.dart';

Future<void> deleteDeck(int id, context) async {
  await DatabaseHelper.deleteDeck(id);
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Successfully deleted a deck!'),
  ));
}
