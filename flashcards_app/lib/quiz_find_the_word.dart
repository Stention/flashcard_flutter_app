import 'package:flashcards_app/summary.dart';
import "package:flutter/material.dart";
import "dart:math";
import 'package:collection/collection.dart';
import "database_helper.dart";

class FindTheWord extends StatefulWidget {
  final int deckId;
  final String deckName;
  final String numberOfQuestions;
  const FindTheWord(
      {Key? key,
      required this.deckId,
      required this.deckName,
      required this.numberOfQuestions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<FindTheWord> {
  List<Map<String, dynamic>> _allWordsPool = [];
  List<Map<String, dynamic>> _gameWordsPool = [];
  int _numberOfQuestions = 0;

  Future<bool?> showWarning(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text(
              "Do you want to exit the game?",
            ),
            actions: [
              ElevatedButton(
                  child: const Text("Yes",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  onPressed: () => setState(() {
                        Navigator.pop(context, true);
                        finalScore = 0;
                        questionNumber = 0;
                      })),
              ElevatedButton(
                child: const Text("No",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
                onPressed: () => Navigator.pop(context, false),
              )
            ]),
      );

  void _createWordsPool() async {
    final data = await DatabaseHelper.getWords(widget.deckName);
    final numberOfQuestions = int.parse(widget.numberOfQuestions);
    setState(() {
      _allWordsPool = data;
      _numberOfQuestions = numberOfQuestions;
      _gameWordsPool = data.sample(numberOfQuestions);
    });
  }

  Future<void> _updateLevel(int id, int level, answer) async {
    await DatabaseHelper.changeLevel(id, level, answer);
  }

  _question(_gameWordsPool) {
    final _random = Random();
    if (_gameWordsPool.isNotEmpty) {
      var wordsPool = _gameWordsPool;
      return wordsPool[_random.nextInt(wordsPool.length)];
    }
  }

  _answers(_allWordsPool, correctAnswer) {
    final _random = Random();
    if (_allWordsPool.isNotEmpty) {
      List answers = [];
      while (answers.length < 3) {
        var word = _allWordsPool[_random.nextInt(_allWordsPool.length)];
        if (word["word"] != correctAnswer && !answers.contains(word["word"])) {
          answers.add(word["word"]);
        }
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
    var question = _question(_gameWordsPool);
    var correctAnswer = question != null ? question["word"] : "no question";
    var answers = _answers(_allWordsPool, correctAnswer);
    question != null ? answers.add(question["word"]) : "no answer";

    var appBar = AppBar(
        backgroundColor: Colors.black,
        title: const Text("Select the right word",
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));

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
                        Text("${questionNumber + 1} / $_numberOfQuestions",
                            style: const TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.bold)),
                        Text("Score: $finalScore",
                            style: const TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.bold))
                      ])),
              SizedBox(
                  height: (MediaQuery.of(context).size.height -
                          appBar.preferredSize.height) /
                      4,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                          question != null
                              ? question["translation"]
                              : "no translation",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 30.0)))),
              ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: answers != null ? answers.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 75,
                      color: Colors.black,
                      child: MaterialButton(
                          child: Text(answers[index],
                              style: const TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: () {
                            if (question["word"] == answers[index]) {
                              debugPrint("Correct");
                              _updateLevel(
                                  question["id"], question["level"], "correct");
                              finalScore++;
                              _gameWordsPool.removeWhere((answer) =>
                                  answer["translation"] ==
                                  question["translation"]);
                            } else {
                              debugPrint("False");
                              _updateLevel(
                                  question["id"], question["level"], "false");
                            }
                            updateQuestion();
                          }));
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ]),
          )),
    );
  }

  void updateQuestion() {
    setState(() {
      if (questionNumber == ((_numberOfQuestions) - 1)) {
        showModalBottomSheet<void>(
            context: context,
            builder: (context) => Summary(
                score: finalScore,
                deckId: widget.deckId,
                deckName: widget.deckName,
                numberOfQuestions: _numberOfQuestions));
      } else {
        questionNumber++;
      }
    });
  }
}
