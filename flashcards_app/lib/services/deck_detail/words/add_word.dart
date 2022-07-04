import 'package:flashcards_app/database_helper.dart';

Future<void> addWord(String word, String translation, String deckName) async {
  await DatabaseHelper.createWord(word, translation, deckName);
}
