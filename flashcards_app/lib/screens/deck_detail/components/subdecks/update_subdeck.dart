import 'package:flashcards_app/database_helper.dart';

Future<void> updateSubdeck(int id, String name) async {
  await DatabaseHelper.updateSubDeck(id, name);
}
