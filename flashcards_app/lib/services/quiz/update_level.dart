import 'package:flashcards_app/database_helper.dart';

Future<void> updateLevel(int id, int level, answer) async {
  await DatabaseHelper.changeLevel(id, level, answer);
}
