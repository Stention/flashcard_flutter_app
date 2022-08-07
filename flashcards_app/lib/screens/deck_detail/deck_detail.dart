import 'package:flashcards_app/screens/deck_detail/components/deck_detail_manager.dart';
import 'package:flashcards_app/screens/deck_detail/components/words_manager.dart';
import 'package:flashcards_app/screens/decks_list/decks_list.dart';
import 'package:flashcards_app/screens/deck_detail/components/forms/show_word_form.dart';
import 'package:flashcards_app/screens/deck_detail/components/forms/show_subdeck_form.dart';
import 'package:flashcards_app/screens/deck_detail/components/forms/speed_dial.dart';
import 'package:flashcards_app/screens/deck_detail/components/forms/deck_detail_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../database_helper.dart';
import '../quiz/quiz_find_the_word.dart';
import '../quiz/quiz_find_translation.dart';

class DeckDetail extends StatefulWidget {
  const DeckDetail({Key? key, required this.deckId, required this.deckName})
      : super(key: key);
  final int deckId;
  final String deckName;

  @override
  _DeckDetailState createState() => _DeckDetailState();
}

class _DeckDetailState extends State<DeckDetail> {
  List<Map<String, dynamic>> _mainDeck = [];
  List<Map<String, dynamic>> _words = [];
  List<Map<String, dynamic>> _wordsWithoutSubdeck = [];
  List<Map<String, dynamic>> _subDecks = [];
  final Map<String, List> _wordsInSubdeck = {};
  bool _isLoading = true;
  int _numberOfQuestions = 10;
  String _targetLanguage = '';

  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _refreshDeck();
  }

  void _refreshDeck() async {
    final deck = await DatabaseHelper.getDecks(widget.deckId);
    final data = await DatabaseHelper.getWords(widget.deckName);
    final wordsWithoutSubdeck =
        await DatabaseHelper.getWordsWithoutSubdeck(widget.deckName);
    final subDecksData = await DatabaseHelper.getSubDecks(widget.deckName);
    if (subDecksData.isNotEmpty) {
      for (int i = 0; i < subDecksData.length; i++) {
        String name = subDecksData[i]['name'];
        List subWords = await DatabaseHelper.getWordsInSubdeck(name);
        _wordsInSubdeck[name] = subWords;
      }
    }

    setState(() {
      _mainDeck = deck;
      _words = data;
      _wordsWithoutSubdeck = wordsWithoutSubdeck;
      _subDecks = subDecksData;
      _isLoading = false;
      _numberOfQuestions = _mainDeck[0]["numberOfWordsToLearn"];
      if (_mainDeck[0]["targetLanguage"] == null) {
        _targetLanguage = '';
      } else {
        _targetLanguage = _mainDeck[0]["targetLanguage"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    tts.setLanguage(_targetLanguage);
    tts.setSpeechRate(0.4);
    return Scaffold(
        //extendBodyBehindAppBar: true,
        endDrawer: DeckDetailDrawer(
            deckId: widget.deckId,
            deckName: widget.deckName,
            targetLanguage: _targetLanguage,
            numberOfQuestions: _numberOfQuestions,
            words: _words,
            refreshDeck: _refreshDeck),
        appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(widget.deckName,
                style: const TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePage())),
            )),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _subDecks.length,
                            itemBuilder: (BuildContext context, int index) {
                              List? wordsInSubdeck =
                                  _wordsInSubdeck[_subDecks[index]['name']];

                              return DragTarget<int>(
                                  builder: (context, data, rejectedItems) {
                                return Slidable(
                                  endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            showSubDeckForm(
                                                _subDecks[index]['id'],
                                                context,
                                                _subDecks,
                                                widget.deckName,
                                                refreshDeck: _refreshDeck);
                                          },
                                          backgroundColor:
                                              const Color(0xFF7BC043),
                                          foregroundColor: Colors.white,
                                          icon: Icons.archive,
                                          label: 'Edit',
                                        ),
                                        SlidableAction(
                                          onPressed: (context) {
                                            DeckDetailManager().deleteSubDeck(
                                                _subDecks[index]['id'], context,
                                                refreshDeck: _refreshDeck);
                                          },
                                          backgroundColor:
                                              const Color(0xFFFE4A49),
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ]),
                                  child: ExpansionTile(
                                    title: Text(_subDecks[index]['name']),
                                    subtitle: Text((wordsInSubdeck?.length ?? 0)
                                            .toString() +
                                        ' word(s)'),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    trailing: SizedBox(
                                      width: 150,
                                      child: Row(children: [
                                        IconButton(
                                            icon: const Icon(
                                                Icons.verified_rounded),
                                            onPressed: () {
                                              if (wordsInSubdeck!.length < 10) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'To play games, you have to add at least 10 words!'),
                                                ));
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            FindTheWord(
                                                                deckId: widget
                                                                    .deckId,
                                                                deckName: widget
                                                                    .deckName,
                                                                questions:
                                                                    wordsInSubdeck,
                                                                numberOfQuestions:
                                                                    _numberOfQuestions)));
                                              }
                                            }),
                                        IconButton(
                                            icon: const Icon(
                                                Icons.verified_user_sharp),
                                            onPressed: () {
                                              if (wordsInSubdeck!.length < 10) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'To play games, you have to add at least 10 words!'),
                                                ));
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            FindTranslation(
                                                                deckId: widget
                                                                    .deckId,
                                                                deckName:
                                                                    widget
                                                                        .deckName,
                                                                questions:
                                                                    wordsInSubdeck,
                                                                numberOfQuestions:
                                                                    _numberOfQuestions)));
                                              }
                                            }),
                                        IconButton(
                                            icon: const Icon(Icons.play_arrow),
                                            onPressed: () {
                                              for (var word
                                                  in wordsInSubdeck!) {
                                                tts.setSpeechRate(0.3);
                                                tts.speak(word["word"]);
                                              }
                                            }),
                                      ]),
                                    ),
                                    children: <Widget>[
                                      ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: wordsInSubdeck != null
                                              ? wordsInSubdeck.length
                                              : 0,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return LongPressDraggable(
                                              data: wordsInSubdeck![index]
                                                  ["id"],
                                              child: SizedBox(
                                                width: 350,
                                                height: 70,
                                                child: ListTile(
                                                    title: Text(
                                                        wordsInSubdeck[index]
                                                            ["word"]),
                                                    subtitle: Text(
                                                        wordsInSubdeck[index]
                                                            ["translation"]),
                                                    trailing: SizedBox(
                                                      width: 100,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          CircularPercentIndicator(
                                                            radius: 12.0,
                                                            percent: WordsManager()
                                                                .setIndicatorPercent(
                                                                    _wordsWithoutSubdeck[
                                                                            index]
                                                                        [
                                                                        "level"]),
                                                            progressColor: WordsManager()
                                                                .setIndicatorColour(
                                                                    _wordsWithoutSubdeck[
                                                                            index]
                                                                        [
                                                                        "level"]),
                                                          ),
                                                          IconButton(
                                                              icon: const Icon(Icons
                                                                  .surround_sound),
                                                              onPressed: () {
                                                                tts.setSpeechRate(
                                                                    0.32);
                                                                tts.speak(
                                                                    wordsInSubdeck[
                                                                            index]
                                                                        [
                                                                        "word"]);
                                                              }),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      showWordForm(
                                                          wordsInSubdeck[index]
                                                              ['id'],
                                                          wordsInSubdeck,
                                                          widget.deckName,
                                                          context,
                                                          refreshDeck:
                                                              _refreshDeck);
                                                    }),
                                              ),
                                              feedback: Material(
                                                  child: Container(
                                                      width: 200,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .greenAccent)),
                                                      child: ListTile(
                                                        title: Text(
                                                          wordsInSubdeck[index]
                                                              ["word"],
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ))),
                                            );
                                          })
                                    ],
                                  ),
                                );
                              }, onAccept: (data) {
                                setState(() {
                                  WordsManager().addWordToSubdeck(
                                      data, _subDecks[index]['name'],
                                      refreshDeck: _refreshDeck);
                                });
                              });
                            }),
                        DragTarget<int>(
                            builder: (context, data, rejectedItems) {
                          return SizedBox(
                            width: 400.0,
                            height: MediaQuery.of(context).size.height,
                            child: ListView.builder(
                                //  physics: const ClampingScrollPhysics(),
                                //   shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: _wordsWithoutSubdeck.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == _wordsWithoutSubdeck.length) {
                                    return const SizedBox(height: 250);
                                  } else {
                                    return LongPressDraggable(
                                        data: _wordsWithoutSubdeck[index]["id"],
                                        child: SizedBox(
                                            width: 350,
                                            height: 70,
                                            child: ListTile(
                                                title: Text(
                                                    _wordsWithoutSubdeck[index]
                                                        ["word"]),
                                                subtitle: Text(
                                                    _wordsWithoutSubdeck[index]
                                                        ["translation"]),
                                                trailing: SizedBox(
                                                  width: 100,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      CircularPercentIndicator(
                                                        radius: 12.0,
                                                        percent: WordsManager()
                                                            .setIndicatorPercent(
                                                                _wordsWithoutSubdeck[
                                                                        index]
                                                                    ["level"]),
                                                        progressColor: WordsManager()
                                                            .setIndicatorColour(
                                                                _wordsWithoutSubdeck[
                                                                        index]
                                                                    ["level"]),
                                                      ),
                                                      IconButton(
                                                          icon: const Icon(Icons
                                                              .surround_sound),
                                                          onPressed: () =>
                                                              tts.speak(
                                                                  _wordsWithoutSubdeck[
                                                                          index]
                                                                      [
                                                                      "word"])),
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  showWordForm(
                                                      _wordsWithoutSubdeck[
                                                          index]['id'],
                                                      _wordsWithoutSubdeck,
                                                      widget.deckName,
                                                      context,
                                                      refreshDeck:
                                                          _refreshDeck);
                                                })),
                                        feedback: Material(
                                            child: Container(
                                                width: 200,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors
                                                            .orangeAccent)),
                                                child: ListTile(
                                                  title: Text(
                                                    _wordsWithoutSubdeck[index]
                                                        ["word"],
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ))));
                                  }
                                }),
                          );
                        }, onAccept: (data) {
                          setState(() {
                            WordsManager().addWordToSubdeck(data, null,
                                refreshDeck: _refreshDeck);
                          });
                        }),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              child: const Icon(Icons.play_arrow, color: Colors.white),
              backgroundColor: Colors.green,
              onPressed: () {
                for (var word in _wordsWithoutSubdeck) {
                  tts.setSpeechRate(0.32);
                  tts.speak(word["word"]);
                }
              },
            ),
            const SizedBox(height: 16),
            buildSpeedDial(widget.deckId, widget.deckName, context, _subDecks,
                _wordsWithoutSubdeck, _numberOfQuestions,
                refreshDeck: _refreshDeck)
          ],
        ));
  }
}
