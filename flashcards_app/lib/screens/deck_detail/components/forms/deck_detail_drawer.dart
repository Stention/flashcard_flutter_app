import 'package:flashcards_app/screens/deck_detail/components/csv_manager.dart';
import 'package:flashcards_app/screens/deck_detail/components/deck_detail_manager.dart';
//import 'package:flashcards_app/screens/deck_detail/components/number_of_questions/change_number_of_questions.dart';
//import 'package:flashcards_app/screens/deck_detail/components/language/change_target_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DeckDetailDrawer extends StatefulWidget {
  final int deckId;
  final String deckName;
  final String targetLanguage;
  final int numberOfQuestions;
  final List words = [];
  final Function refreshDeck;
  DeckDetailDrawer(
      {Key? key,
      required this.deckId,
      required this.deckName,
      required this.targetLanguage,
      required this.numberOfQuestions,
      required words,
      required this.refreshDeck})
      : super(key: key);

  @override
  _DeckDetailDrawerState createState() => _DeckDetailDrawerState();
}

class _DeckDetailDrawerState extends State<DeckDetailDrawer> {
  final FlutterTts tts = FlutterTts();
  List _listOfLanguages = [];
  //  List _listOfVoices = [];

  @override
  void initState() {
    super.initState();
    _getLanguages();
  }

  void _getLanguages() async {
    List<Object?> languages = await tts.getLanguages;
    //List<dynamic> voices = await tts.getVoices;
    setState(() {
      _listOfLanguages = languages;
      // _listOfVoices = voices;
    });
  }

  @override
  Widget build(BuildContext context) {
    var languages = _listOfLanguages.map((item) => item as String).toList();
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
          onTap: () => CsvManager().uploadCsvFile(widget.deckName, context,
              refreshDeck: widget.refreshDeck)),
      ListTile(
        title: const Text('Download Words file'),
        onTap: () => CsvManager()
            .generateCsvFile(widget.deckName, widget.words, context),
      ),
      const ListTile(
        title: Text('How many words you want to learn?'),
      ),
      ListTile(
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
            Widget>[
          ElevatedButton(
            child: Text(widget.numberOfQuestions == 10 ? '10' : '10'),
            style: ElevatedButton.styleFrom(
              primary: widget.numberOfQuestions == 10 ? Colors.purple : null,
            ),
            onPressed: () => DeckDetailManager().changeNumberOfQuestions(
                widget.deckId, 10,
                refreshDeck: widget.refreshDeck),
          ),
          ElevatedButton(
            child: Text(widget.numberOfQuestions == 30 ? '30' : '30'),
            style: ElevatedButton.styleFrom(
              primary: widget.numberOfQuestions == 30 ? Colors.purple : null,
            ),
            onPressed: () => DeckDetailManager().changeNumberOfQuestions(
                widget.deckId, 30,
                refreshDeck: widget.refreshDeck),
          ),
          ElevatedButton(
            child: Text(widget.numberOfQuestions == 50 ? '50' : '50'),
            style: ElevatedButton.styleFrom(
              primary: widget.numberOfQuestions == 50 ? Colors.purple : null,
            ),
            onPressed: () => DeckDetailManager().changeNumberOfQuestions(
                widget.deckId, 50,
                refreshDeck: widget.refreshDeck),
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
                hint: Text(widget.targetLanguage.toString()),
                items: languages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  DeckDetailManager().changeTargetLanguage(
                      widget.deckId, value.toString(),
                      refreshDeck: widget.refreshDeck);
                },
              ),
            ]),
      ),
    ]));
  }
}
