import 'dart:math';
import 'package:flashcards_app/database_helper.dart';

class QuizManager {
  dynamic getQuestion(List<dynamic> gameWordsPool) {
    if (gameWordsPool.isNotEmpty) {
      return gameWordsPool[Random().nextInt(gameWordsPool.length)];
    }
  }

  List<dynamic>? getAnswers(List<dynamic> allWordsPool, dynamic correctAnswer) {
    if (allWordsPool.isNotEmpty) {
      List answers = [];
      while (answers.length < 3) {
        var word = allWordsPool[Random().nextInt(allWordsPool.length)];
        if (word["word"] != correctAnswer && !answers.contains(word["word"])) {
          answers.add(word["word"]);
        }
      }
      return answers;
    } else {
      return null;
    }
  }

  Future<void> updateLevel(int id, int level, String answer) async {
    await DatabaseHelper.changeLevel(id, level, answer);
  }
}
