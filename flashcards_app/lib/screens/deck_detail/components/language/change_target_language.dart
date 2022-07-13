import 'package:flashcards_app/database_helper.dart';

Future<void> changeTargetLanguage(int deckId, String targetLanguage,
    {required refreshDeck}) async {
  await DatabaseHelper.updateDeckTargetLanguage(deckId, targetLanguage);
  refreshDeck();
}
