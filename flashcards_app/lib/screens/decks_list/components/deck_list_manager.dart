import 'package:flutter/material.dart';
import 'package:flashcards_app/database_helper.dart';

class DeckManager {
  Future<void> addDeck(String name) async {
    await DatabaseHelper.createDeck(name);
  }

  Future<void> updateDeck(int id, String name) async {
    await DatabaseHelper.updateDeck(id, name);
  }

  Future<void> deleteDeck(int id, dynamic context) async {
    await DatabaseHelper.deleteDeck(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a deck!'),
    ));
  }
}
