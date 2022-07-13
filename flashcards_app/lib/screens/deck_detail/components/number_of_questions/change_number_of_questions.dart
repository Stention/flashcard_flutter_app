import 'package:flashcards_app/database_helper.dart';

Future<void> changeNumberOfQuestions(int deckId, int numberOfQuestions,
    {required refreshDeck}) async {
  await DatabaseHelper.updateDeckWordsCount(deckId, numberOfQuestions);
  refreshDeck();
}
