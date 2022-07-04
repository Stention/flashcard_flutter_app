import 'dart:math';

getAnswers(allWordsPool, correctAnswer) {
  final random = Random();
  if (allWordsPool.isNotEmpty) {
    List answers = [];
    while (answers.length < 3) {
      var word = allWordsPool[random.nextInt(allWordsPool.length)];
      if (word["word"] != correctAnswer && !answers.contains(word["word"])) {
        answers.add(word["word"]);
      }
    }
    return answers;
  }
}
