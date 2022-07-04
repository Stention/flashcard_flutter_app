import 'package:flashcards_app/database_helper.dart';

Future<void> addWordToSubdeck(int id, String? subDeckName,
    {required refreshDeck}) async {
  await DatabaseHelper.updateWordsSubdeck(id, subDeckName);
  refreshDeck();
}
