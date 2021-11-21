import 'package:flutter/material.dart';
import 'deck_games.dart';

class DeckDetail extends StatelessWidget {
  final int id;
  final String name;
  const DeckDetail({Key? key, required this.id, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text(name + " Games"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GamesDetail(
                        id: id,
                        name: name,
                      )),
            );
          },
        ),
      ),
    );
  }
}
