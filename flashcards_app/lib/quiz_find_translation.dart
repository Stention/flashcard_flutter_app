import 'package:flashcards_app/services/quiz/get_answers.dart';
import 'package:flashcards_app/services/quiz/update_level.dart';
import 'package:flashcards_app/services/quiz/get_question.dart';
import 'package:flashcards_app/summary.dart';
import "package:flutter/material.dart";
import 'package:collection/collection.dart';

class FindTranslation extends StatefulWidget {
  final int deckId;
  final String deckName;
  final List questions;
  final int numberOfQuestions;
  const FindTranslation(
      {Key? key,
      required this.deckId,
      required this.deckName,
      required this.questions,
      required this.numberOfQuestions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<FindTranslation> {
  List<dynamic> _allWordsPool = [];
  List<dynamic> _gameWordsPool = [];
  int _numberOfQuestions = 0;

  Future<bool?> showWarning(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Do you want to exit the game?"),
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
    final data = widget.questions;
    final numberOfQuestions = widget.numberOfQuestions;
    setState(() {
      _allWordsPool = data;
      _numberOfQuestions = numberOfQuestions;
      _gameWordsPool = data.sample(numberOfQuestions);
    });
  }

  @override
  void initState() {
    super.initState();
    _createWordsPool();
  }

  @override
  Widget build(BuildContext context) {
    var question = getQuestion(_gameWordsPool);
    var correctAnswer = question != null ? question["translation"] : "no data";
    var answers = getAnswers(_allWordsPool, correctAnswer);
    question != null ? answers.add(question["translation"]) : "no data";
    answers.shuffle();

    var appBar = AppBar(
        backgroundColor: Colors.black,
        title: const Text("Select the right translation",
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
                              ? question["word"]
                              : "no more questions",
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
                            if (question["translation"] == answers[index]) {
                              debugPrint("Correct");
                              updateLevel(
                                  question["id"], question["level"], "correct");
                              finalScore++;
                              _gameWordsPool.removeWhere((answer) =>
                                  answer["word"] == question["word"]);
                            } else {
                              debugPrint("False");
                              updateLevel(
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
                  numberOfQuestions: _numberOfQuestions,
                ));
      } else {
        questionNumber++;
      }
    });
  }
}
