import 'package:flashcards_app/database_helper.dart';
import 'package:flutter/material.dart';

void deleteSubDeck(int id, dynamic context, {required refreshDeck}) async {
  await DatabaseHelper.deleteSubDeck(id);
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Successfully deleted a subdeck!'),
  ));
  refreshDeck();
}
