import 'package:flutter/material.dart';
import 'game_choose_from_4.dart';

class GamesDetail extends StatelessWidget {
  final int id;
  final String name;
  const GamesDetail({Key? key, required this.id, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name + " Games"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Find the translation"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChooseFrom4Game(
                        id: id,
                      )),
            );
          },
        ),
      ),
    );
  }
}