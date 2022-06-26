import 'package:flashcards_app/database_helper.dart';

Future<void> addDeck(String name) async {
  await DatabaseHelper.createDeck(name);
}
