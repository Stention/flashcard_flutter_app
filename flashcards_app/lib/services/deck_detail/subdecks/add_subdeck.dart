import 'package:flashcards_app/database_helper.dart';

Future<void> addSubdeck(String name, String deckName) async {
  await DatabaseHelper.createSubDeck(name, deckName);
}
