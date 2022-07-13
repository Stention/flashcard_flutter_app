import 'package:flashcards_app/database_helper.dart';

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
}
