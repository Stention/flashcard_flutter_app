import 'package:flashcards_app/database_helper.dart';
import 'package:flutter/material.dart';

class WordsManager {
  Future<void> addWord(String word, String translation, String deckName) async {
    await DatabaseHelper.createWord(word, translation, deckName);
  }

  Future<void> updateWord(int id, String word, String translation) async {
    await DatabaseHelper.updateWord(id, word, translation);
  }

  Future<void> deleteWord(int id) async {
    await DatabaseHelper.deleteWord(id);
  }

  Future<void> addWordToSubdeck(int id, String? subDeckName,
      {required refreshDeck}) async {
    await DatabaseHelper.updateWordsSubdeck(id, subDeckName);
    refreshDeck();
  }

  double setIndicatorPercent(int level) {
    double percent = level.toDouble() / 10;
    return percent;
  }

  dynamic setIndicatorColour(int level) {
    if (level == 0) {
      Color color = const Color(0x00000000);
      return color;
    } else if (level > 0 && level <= 2) {
      Color color = Colors.red;
      return color;
    } else if (level > 2 && level <= 5) {
      Color color = Colors.orange;
      return color;
    } else if (level > 5 && level <= 7) {
      Color color = Colors.yellow;
      return color;
    } else if (level > 7 && level <= 9) {
      Color color = Colors.lightGreen;
      return color;
    } else if (level > 9 && level <= 10) {
      Color color = Colors.green;
      return color;
    }
  }
}
