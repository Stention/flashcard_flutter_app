import 'package:flashcards_app/database_helper.dart';

Future<void> updateWord(int id, String word, String translation) async {
  await DatabaseHelper.updateWord(id, word, translation);
}
