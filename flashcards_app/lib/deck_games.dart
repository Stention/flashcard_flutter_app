import 'package:flutter/material.dart';
import 'game_choose_from_4.dart';

class GamesDetail extends StatelessWidget {
  final int deckId;
  final String deckName;
  const GamesDetail({Key? key, required this.deckId, required this.deckName})
      : super(key: key);

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
              MaterialPageRoute(
                  builder: (context) => ChooseFrom4Game(
                        deckId: deckId,
                        deckName: deckName,
                      )),
            );
          },
        ),
      ),
    );
  }
}
