import 'package:flashcards_app/database_helper.dart';

Future<void> deleteWord(int id) async {
  await DatabaseHelper.deleteWord(id);
}
