import "package:flutter/material.dart";
import "dart:math";
import "database_helper.dart";

var finalScore = 0;
var questionNumber = 0;
var numberOfQuestions = 5;

class Quiz extends StatefulWidget {
  final int deckId;
  final String deckName;
  const Quiz({Key? key, required this.deckId, required this.deckName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return QuizState();
  }
}

class QuizState extends State<Quiz> {
  List<Map<String, dynamic>> _words = [];

  void _refreshDecks() async {
    final data = await DatabaseHelper.getWords(widget.deckName);
    setState(() {
      _words = data;
    });
  }

  _createWordsPool() {
    final _random = Random();
    var wordsPool = List.generate(
        numberOfQuestions, (_) => _words[_random.nextInt(_words.length)]);

    return wordsPool;
  }

  _question(pool) {
    final _random = Random();
    var wordsPool = pool;
    var index = _random.nextInt(wordsPool.length);
    return wordsPool[index];
  }

  _answers(pool) {
    final _random = Random();
    var wordsPool = pool;
    var answersPool =
        List.generate(3, (_) => wordsPool[_random.nextInt(wordsPool.length)]);
    List answers = [];
    for (var word in answersPool) {
      answers.add(word["translation"]);
    }
    return answers;
  }

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  @override
  Widget build(BuildContext context) {
    var _wordsPool = _createWordsPool();
    print(_wordsPool);
    var question = _question(_wordsPool);
    var answers = _answers(_wordsPool);
    answers.add(question["translation"]);

    var appBar = AppBar(title: const Text("Find the right translation"));
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: appBar,
          body: Container(
            margin: const EdgeInsets.all(10.0),
            alignment: Alignment.topCenter,
            child: Column(children: <Widget>[
              Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                            "Question ${questionNumber + 1} of $numberOfQuestions",
                            style: const TextStyle(fontSize: 22.0)),
                        Text("Score: $finalScore",
                            style: const TextStyle(fontSize: 22.0))
                      ])),
              SizedBox(
                  height: (MediaQuery.of(context).size.height -
                          appBar.preferredSize.height) /
                      4,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(question["word"],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 40.0)))),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  margin: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
                  color: Colors.orange,
                  child: MaterialButton(
                      child: Text(answers[0],
                          style: const TextStyle(
                              fontSize: 20.0, color: Colors.white)),
                      onPressed: () {
                        if (question["translation"] == answers[0]) {
                          debugPrint("Correct");
                          finalScore++;
                          _wordsPool.remove(question["word"]);
                          // _wordsPool.removeWhere(
                          //     (item) => item.word == question["word"]);
                        } else {
                          debugPrint("False");
                        }
                        updateQuestion();
                      })),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  margin: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
                  color: Colors.orange,
                  child: MaterialButton(
                      child: Text(answers[1],
                          style: const TextStyle(
                              fontSize: 20.0, color: Colors.white)),
                      onPressed: () {
                        if (question["translation"] == answers[1]) {
                          debugPrint("Correct");
                          finalScore++;
                          _wordsPool.remove(question["word"]);
                          //  wordsPool.removeWhere(
                          //    (word) => word.word == question["word"]);
                        } else {
                          debugPrint("False");
                        }
                        updateQuestion();
                      })),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  margin: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
                  color: Colors.orange,
                  child: MaterialButton(
                      child: Text(answers[2],
                          style: const TextStyle(
                              fontSize: 20.0, color: Colors.white)),
                      onPressed: () {
                        if (question["translation"] == answers[2]) {
                          debugPrint("Correct");
                          finalScore++;
                          _wordsPool.remove(question["word"]);
                          //  wordsPool.removeWhere(
                          //     (word) => word.word == question["word"]);
                        } else {
                          debugPrint("False");
                        }
                        updateQuestion();
                      })),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  margin: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
                  color: Colors.orange,
                  child: MaterialButton(
                      child: Text(answers[3],
                          style: const TextStyle(
                              fontSize: 20.0, color: Colors.white)),
                      onPressed: () {
                        if (question["translation"] == answers[3]) {
                          debugPrint("Correct");
                          finalScore++;
                          _wordsPool.remove(question["word"]);
                          //  wordsPool.removeWhere(
                          //     (word) => word.word == question["word"]);
                        } else {
                          debugPrint("False");
                        }
                        updateQuestion();
                      })),
              Container(
                  alignment: Alignment.bottomCenter,
                  child: MaterialButton(
                      minWidth: 240.0,
                      height: 30.0,
                      onPressed: resetQuiz,
                      child: const Text("Quit",
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.white))))
            ]),
          )),
    );
  }

  void resetQuiz() {
    setState(() {
      Navigator.pop(context);
      finalScore = 0;
      questionNumber = 0;
    });
  }

  void updateQuestion() {
    setState(() {
      if (questionNumber == (numberOfQuestions - 1)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Summary(score: finalScore)));
      } else {
        questionNumber++;
      }
    });
  }
}

class Summary extends StatelessWidget {
  final int score;
  const Summary({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Final score: $score", style: const TextStyle(fontSize: 25.0)),
            const Padding(padding: EdgeInsets.all(10.0)),
            MaterialButton(
                color: Colors.red,
                onPressed: () {
                  questionNumber = 0;
                  finalScore = 0;
                  Navigator.pop(context);
                },
                child: const Text("Reset Quiz",
                    style: TextStyle(fontSize: 20.0, color: Colors.white)))
          ],
        ),
      ),
    );
  }
}
