import 'package:flutter/material.dart';
import 'deck_games.dart';

var finalScore = 0;
var questionNumber = 0;

class Summary extends StatelessWidget {
  final int score;
  final int numberOfQuestions;
  final String deckId;
  final String deckName;
  const Summary(
      {Key? key,
      required this.score,
      required this.numberOfQuestions,
      required this.deckId,
      required this.deckName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text("Final score: $score / $numberOfQuestions",
                  style: const TextStyle(fontSize: 25.0)),
              const Padding(padding: EdgeInsets.all(10.0)),
              MaterialButton(
                color: Colors.grey,
                child: const Text("Back to games",
                    style: TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: () {
                  finalScore = 0;
                  questionNumber = 0;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GamesDetail(deckId: deckId, deckName: deckName)));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
