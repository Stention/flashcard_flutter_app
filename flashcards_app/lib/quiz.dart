import "package:flutter/material.dart";
import "dart:math";
import 'package:collection/collection.dart';
import "database_helper.dart";
import 'deck_games.dart';

var finalScore = 0;
var questionNumber = 0;
//var numberOfQuestions = 5;

class Quiz extends StatefulWidget {
  final String deckName;
  final String numberOfQuestions;
  const Quiz(
      {Key? key, required this.deckName, required this.numberOfQuestions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return QuizState();
  }
}

class QuizState extends State<Quiz> {
  List<Map<String, dynamic>> _wordsPool = [];
  int _numberOfQuestions = 0;
  Future<bool?> showWarning(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Do you want to exit app?"),
            actions: [
              ElevatedButton(
                child: const Text("Yes"),
                onPressed: () => Navigator.pop(context, true),
              ),
              ElevatedButton(
                child: const Text("No"),
                onPressed: () => Navigator.pop(context, false),
              )
            ]),
      );

  void _createWordsPool() async {
    final data = await DatabaseHelper.getWords(widget.deckName);
    final numberOfQuestions = int.parse(widget.numberOfQuestions);
    setState(() {
      _numberOfQuestions = numberOfQuestions;
      _wordsPool = data.sample(numberOfQuestions);
    });
  }

  _question(pool) {
    final _random = Random();
    if (pool.isNotEmpty) {
      var wordsPool = pool;
      return wordsPool[_random.nextInt(wordsPool.length)];
    }
  }

  _answers(pool) {
    final _random = Random();
    if (pool.isNotEmpty) {
      var wordsPool = pool;
      var answersPool =
          List.generate(3, (_) => wordsPool[_random.nextInt(wordsPool.length)]);
      List answers = [];
      for (var word in answersPool) {
        answers.add(word["translation"]);
      }
      return answers;
    }
  }

  @override
  void initState() {
    super.initState();
    _createWordsPool();
  }

  @override
  Widget build(BuildContext context) {
    var question = _question(_wordsPool);
    var answers = _answers(_wordsPool);
    question != null ? answers.add(question["translation"]) : "no data";

    var appBar = AppBar(title: const Text("Find the right translation"));
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
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
                            "Question ${questionNumber + 1} of $_numberOfQuestions",
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
                      child: Text(
                          question != null ? question["word"] : "no data",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 40.0)))),
              ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: answers != null ? answers.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 75,
                      color: Colors.orange,
                      child: MaterialButton(
                          child: Text(answers[index],
                              style: const TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: () {
                            if (question["translation"] == answers[index]) {
                              debugPrint("Correct");
                              finalScore++;
                              _wordsPool.removeWhere(
                                  (item) => item["word"] == question["word"]);
                            } else {
                              debugPrint("False");
                            }
                            updateQuestion();
                          }));
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  child: MaterialButton(
                    minWidth: 240.0,
                    height: 30.0,
                    child: const Text("Quit",
                        style: TextStyle(fontSize: 18.0, color: Colors.blue)),
                    onPressed: resetQuiz,
                  ))
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
      if (questionNumber == ((_numberOfQuestions) - 1)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Summary(score: finalScore, deckName: widget.deckName)));
      } else {
        questionNumber++;
      }
    });
  }
}

class Summary extends StatelessWidget {
  final int score;
  final String deckName;
  const Summary({Key? key, required this.score, required this.deckName})
      : super(key: key);

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
              child: const Text("Back to games",
                  style: TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GamesDetail(deckName: deckName)));
              },
            )
          ],
        ),
      ),
    );
  }
}
