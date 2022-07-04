import 'package:flashcards_app/filter_words.dart';
import 'package:flashcards_app/quiz_find_the_word.dart';
import 'package:flashcards_app/quiz_find_translation.dart';
import 'package:flashcards_app/services/deck_detail/show_subdeck_form.dart';
import 'package:flashcards_app/services/deck_detail/show_word_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

SpeedDial buildSpeedDial(int deckId, String deckName, dynamic context,
    List subDecks, List words, int numberOfQuestions,
    {required refreshDeck}) {
  return SpeedDial(
    animatedIcon: AnimatedIcons.menu_close,
    animatedIconTheme: const IconThemeData(size: 28.0),
    backgroundColor: Colors.grey[800],
    visible: true,
    curve: Curves.bounceInOut,
    children: [
      SpeedDialChild(
        child: const Icon(Icons.search, color: Colors.white),
        backgroundColor: Colors.black,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FilterWords(
                        deckId: deckId,
                        deckName: deckName,
                      )));
        },
        label: 'Search in deck',
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      SpeedDialChild(
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green[800],
        onTap: () => showSubDeckForm(null, context, subDecks, deckName,
            refreshDeck: refreshDeck),
        label: 'add subdeck',
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      SpeedDialChild(
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.black,
        onTap: () {
          showWordForm(null, words, deckName, context,
              refreshDeck: refreshDeck);
        },
        label: 'add word',
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      SpeedDialChild(
        child: const Icon(Icons.verified_rounded, color: Colors.white),
        backgroundColor: Colors.black,
        onTap: () {
          if (words.length < 10) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('To play games, you have to add at least 10 words!'),
            ));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FindTheWord(
                        deckId: deckId,
                        deckName: deckName,
                        questions: words,
                        numberOfQuestions: numberOfQuestions)));
          }
        },
        label: 'Play "Find the word"',
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      SpeedDialChild(
        child: const Icon(Icons.view_comfy, color: Colors.white),
        backgroundColor: Colors.green[800],
        onTap: () {
          if (words.length < 10) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('To play games, you have to add at least 10 words!'),
            ));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FindTranslation(
                        deckId: deckId,
                        deckName: deckName,
                        questions: words,
                        numberOfQuestions: numberOfQuestions)));
          }
        },
        label: 'Play "Find the translation"',
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
    ],
  );
}
