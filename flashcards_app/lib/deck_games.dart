import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'quiz_find_the_word.dart';
import 'quiz_find_translation.dart';
import 'deck_detail.dart';

class GamesDetail extends StatelessWidget {
  final String deckName;
  final TextEditingController _numberOfQuestions = TextEditingController();

  GamesDetail({Key? key, required this.deckName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(deckName + " Games"),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DeckDetail(deckName: deckName))),
          )),
      body: Center(
        child: Column(children: <Widget>[
          ElevatedButton(
            child: const Text("Find the word"),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                          title: const Text(
                              "How many words do you wanna play with?"),
                          content: TextField(
                            controller: _numberOfQuestions,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          actions: [
                            TextButton(
                                child: const Text("Play"),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FindTheWord(
                                              deckName: deckName,
                                              numberOfQuestions:
                                                  _numberOfQuestions.text)));
                                }),
                          ]));
            },
          ),
          ElevatedButton(
            child: const Text("Find the translation"),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                          title: const Text(
                              "How many words do you wanna play with?"),
                          content: TextField(
                            controller: _numberOfQuestions,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          actions: [
                            TextButton(
                                child: const Text("Play"),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FindTranslation(
                                              deckName: deckName,
                                              numberOfQuestions:
                                                  _numberOfQuestions.text)));
                                }),
                          ]));
            },
          ),
        ]),
      ),
    );
  }
}
