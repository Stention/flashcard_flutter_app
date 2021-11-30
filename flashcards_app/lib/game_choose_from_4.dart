import 'package:flutter/material.dart';
import "dart:math";
import "database_helper.dart";

class ChooseFrom4Game extends StatefulWidget {
  final int deckId;
  final String deckName;
  const ChooseFrom4Game(
      {Key? key, required this.deckId, required this.deckName})
      : super(key: key);

  @override
  _ChooseFrom4GameState createState() => _ChooseFrom4GameState();
}

class _ChooseFrom4GameState extends State<ChooseFrom4Game> {
  List<Map<String, dynamic>> _words = [];

  void _refreshDecks() async {
    final data = await DatabaseHelper.getWords(widget.deckName);
    setState(() {
      _words = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  void _listToPlayWith() {
    final _random = Random();
    var listToPlayWith = [];
    listToPlayWith =
        List.generate(4, (_) => _words[_random.nextInt(_words.length)]);
  }

  void _chooseFrom4Game() {
    var listToPlayWith = _listToPlayWith();
    var correctWord = [];
    var falseWords = [];
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(title: const Text("Find the right translation"));
    return Scaffold(
      appBar: appBar,
      body: Column(children: [
        SizedBox(
            height: (MediaQuery.of(context).size.height -
                    appBar.preferredSize.height) /
                4,
            width: MediaQuery.of(context).size.width,
            child: const Center(
                child: Text("slovo",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 40.0)))),
        Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            margin: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
            color: Colors.orange,
            child: TextButton(
                child: const Text("1"),
                onPressed: () {
                  _listToPlayWith();
                })),
        Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            margin: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
            color: Colors.orange,
            child: TextButton(child: const Text("2"), onPressed: () {})),
        Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            margin: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
            color: Colors.orange,
            child: TextButton(child: const Text("3"), onPressed: () {})),
        Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            margin: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
            color: Colors.orange,
            child: TextButton(child: const Text("4"), onPressed: () {})),
      ]),
    );
  }
}
