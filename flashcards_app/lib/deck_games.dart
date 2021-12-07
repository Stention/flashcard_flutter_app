import 'package:flutter/material.dart';
import 'quiz.dart';

class GamesDetail extends StatelessWidget {
  final String deckName;
  const GamesDetail({Key? key, required this.deckName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deckName + " Games"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Find the translation"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Quiz(deckName: deckName)),
            );
          },
        ),
      ),
    );
  }
}
