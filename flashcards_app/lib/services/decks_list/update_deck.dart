import 'package:flashcards_app/database_helper.dart';

Future<void> updateDeck(int id, String name) async {
  await DatabaseHelper.updateDeck(id, name);
}
