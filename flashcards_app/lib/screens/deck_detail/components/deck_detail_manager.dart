import 'package:flashcards_app/database_helper.dart';
import 'package:flutter/material.dart';

class DeckDetailManager {
  Future<void> addSubdeck(String name, String deckName) async {
    await DatabaseHelper.createSubDeck(name, deckName);
  }

  Future<void> updateSubdeck(int id, String name) async {
    await DatabaseHelper.updateSubDeck(id, name);
  }

  void deleteSubDeck(int id, dynamic context, {required refreshDeck}) async {
    await DatabaseHelper.deleteSubDeck(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a subdeck!'),
    ));
    refreshDeck();
  }

  Future<void> changeTargetLanguage(int deckId, String targetLanguage,
      {required refreshDeck}) async {
    await DatabaseHelper.updateDeckTargetLanguage(deckId, targetLanguage);
    refreshDeck();
  }

  Future<void> changeNumberOfQuestions(int deckId, int numberOfQuestions,
      {required refreshDeck}) async {
    await DatabaseHelper.updateDeckWordsCount(deckId, numberOfQuestions);
    refreshDeck();
  }
}
