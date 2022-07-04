import 'package:flashcards_app/services/deck_detail/change_number_of_questions.dart';
import 'package:flashcards_app/services/deck_detail/change_target_language.dart';
import 'package:flashcards_app/services/deck_detail/generate_csv.dart';
import 'package:flashcards_app/services/deck_detail/upload_csv.dart';
import 'package:flutter/material.dart';

class DeckDetailDrawer extends StatelessWidget {
  final int deckId;
  final String deckName;
  final String targetLanguage;
  final int numberOfQuestions;
  final List words = [];
  final List listOfLanguages = [];
  final Function refreshDeck;
  DeckDetailDrawer(
      {Key? key,
      required this.deckId,
      required this.deckName,
      required this.targetLanguage,
      required this.numberOfQuestions,
      required words,
      required listOfLanguages,
      required this.refreshDeck})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var languages = listOfLanguages.map((item) => item as String).toList();
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
      const DrawerHeader(
          child: Align(
            alignment: Alignment.center,
            child: Text("Menu",
                style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
          ),
          decoration: BoxDecoration(color: Colors.black)),
      ListTile(
        title: const Text('Upload Words file'),
        onTap: () => uploadCsvFile(deckName, context, refreshDeck: refreshDeck),
      ),
      ListTile(
        title: const Text('Download Words file'),
        onTap: () => generateCsvFile(deckName, words, context),
      ),
      const ListTile(
        title: Text('How many words you want to learn?'),
      ),
      ListTile(
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
            Widget>[
          ElevatedButton(
            child: Text(numberOfQuestions == 10 ? '10' : '10'),
            style: ElevatedButton.styleFrom(
              primary: numberOfQuestions == 10 ? Colors.purple : null,
            ),
            onPressed: () =>
                changeNumberOfQuestions(deckId, 10, refreshDeck: refreshDeck),
          ),
          ElevatedButton(
            child: Text(numberOfQuestions == 30 ? '30' : '30'),
            style: ElevatedButton.styleFrom(
              primary: numberOfQuestions == 30 ? Colors.purple : null,
            ),
            onPressed: () =>
                changeNumberOfQuestions(deckId, 30, refreshDeck: refreshDeck),
          ),
          ElevatedButton(
            child: Text(numberOfQuestions == 50 ? '50' : '50'),
            style: ElevatedButton.styleFrom(
              primary: numberOfQuestions == 50 ? Colors.purple : null,
            ),
            onPressed: () =>
                changeNumberOfQuestions(deckId, 50, refreshDeck: refreshDeck),
          )
        ]),
      ),
      const ListTile(
        title: Text('Choose target language'),
      ),
      ListTile(
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DropdownButton<String>(
                hint: Text(targetLanguage.toString()),
                items: languages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  changeTargetLanguage(deckId, value.toString(),
                      refreshDeck: refreshDeck);
                },
              ),
            ]),
      ),
    ]));
  }
}
