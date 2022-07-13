import 'package:flashcards_app/screens/decks_list/decks_list.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Flashcards app",
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
