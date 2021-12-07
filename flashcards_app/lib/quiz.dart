import "package:flutter/material.dart";
import "dart:math";
import "database_helper.dart";

var finalScore = 0;
var questionNumber = 0;
var numberOfQuestions = 4;

class Quiz extends StatefulWidget {
  final String deckName;
  const Quiz({Key? key, required this.deckName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return QuizState();
  }
}

class QuizState extends State<Quiz> {
  List<Map<String, dynamic>> _wordsPool = [];
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
    final _random = Random();
    final data = await DatabaseHelper.getWords(widget.deckName);
    List<Map<String, dynamic>> wordsPool = [];
    while (wordsPool.length < (numberOfQuestions + 1)) {
      var newWord = data[_random.nextInt(data.length)];
      wordsPool.add(newWord);
      if (!wordsPool.contains(newWord)) {
        wordsPool.add(newWord);
      }
    }
    setState(() {
      _wordsPool = wordsPool;
    });
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
    _createWordsPool();
  }

  @override
  Widget build(BuildContext context) {
    var question = _question(_wordsPool);
    var answers = _answers(_wordsPool);
    answers.add(question["translation"]);

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
              ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: 4,
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
                              //   _wordsPool.removeWhere(
                              //     (item) => item["word"] == question["word"]);
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
