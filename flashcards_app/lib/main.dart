import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text(
          "Flashcards",
        ),
      ),
      body: const Center(
        child: Text("1. Němčina"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            // do stuff
          },
          child: const Icon(Icons.navigation),
          backgroundColor: Colors.red),
    ));
  }
}
