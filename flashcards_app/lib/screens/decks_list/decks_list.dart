import 'package:flashcards_app/database_helper.dart';
import 'package:flashcards_app/screens/deck_detail/deck_detail.dart';
import 'package:flashcards_app/screens/decks_list/components/show_deck_form.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  void _refreshDecks() async {
    final data = await DatabaseHelper.getDecks(null);
    setState(() {
      _decks = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Language Decks',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              scrollDirection: Axis.vertical,
              itemCount: _decks.length,
              itemBuilder: (BuildContext context, int index) => Card(
                color: Colors.grey[800],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_decks[index]['name'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                showDeckForm(
                                    _decks[index]['id'], context, _decks,
                                    refreshDeck: _refreshDecks);
                              }),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeckDetail(
                                deckId: _decks[index]['id'],
                                deckName: _decks[index]['name'])),
                      );
                    }),
              ),
            ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: Colors.grey[800],
          onPressed: () {
            showDeckForm(null, context, _decks, refreshDeck: _refreshDecks);
          }),
    );
  }
}
