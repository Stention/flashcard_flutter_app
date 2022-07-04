import 'dart:math';

getQuestion(gameWordsPool) {
  final random = Random();
  if (gameWordsPool.isNotEmpty) {
    var wordsPool = gameWordsPool;
    return wordsPool[random.nextInt(wordsPool.length)];
  }
}
