import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'quiz_find_the_word.dart';
import 'quiz_find_translation.dart';
import 'deck_detail.dart';

class GamesDetail extends StatelessWidget {
  final String deckId;
  final String deckName;
  final TextEditingController _numberOfQuestions = TextEditingController();

  GamesDetail({Key? key, required this.deckId, required this.deckName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(deckName + " Games",
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          leading: IconButton(
            color: Colors.black,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DeckDetail(deckId: deckId, deckName: deckName))),
          )),
      body: Center(
        child: Column(children: <Widget>[
          ElevatedButton(
            child: const Text("Find the word",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black)),
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
                                              deckId: deckId,
                                              deckName: deckName,
                                              numberOfQuestions:
                                                  _numberOfQuestions.text)));
                                }),
                          ]));
            },
          ),
          ElevatedButton(
            child: const Text("Find the translation",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black)),
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
                                              deckId: deckId,
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
