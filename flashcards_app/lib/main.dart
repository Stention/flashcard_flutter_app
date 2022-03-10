import 'package:flutter/material.dart';
import "database_helper.dart";
import "deck_detail.dart";

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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _mainDecks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  void _refreshDecks() async {
    final data = await DatabaseHelper.getDecks(null);
    setState(() {
      _mainDecks = data;
      _isLoading = false;
    });
  }

  Future<void> _addDeck() async {
    await DatabaseHelper.createDeck(_nameController.text);
    _refreshDecks();
  }

  Future<void> _updateDeck(int id) async {
    await DatabaseHelper.updateDeck(id, _nameController.text);
    _refreshDecks();
  }

  void _deleteDeck(int id) async {
    await DatabaseHelper.deleteDeck(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a deck!'),
    ));
    _refreshDecks();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingDeck = _mainDecks.firstWhere((deck) => deck['id'] == id);
      _nameController.text = existingDeck['name'];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        builder: (_) => Container(
              // padding: const EdgeInsets.all(15),
              padding: MediaQuery.of(context).viewInsets,
              width: double.infinity,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Deck name',
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            child: Text(
                                id == null ? 'Create New' : 'Update the Deck',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                            onPressed: () async {
                              if (id == null) {
                                await _addDeck();
                              }
                              if (id != null) {
                                await _updateDeck(id);
                              }
                              _nameController.text = '';
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: Text(id == null ? 'Nix' : 'Delete the Deck',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                            onPressed: () async {
                              if (id != null) {
                                _deleteDeck(id);
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ])
                  ],
                ),
              ),
            ));
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
          : ListView.builder(
              itemCount: _mainDecks.length,
              itemBuilder: (BuildContext context, int index) => Card(
                color: Colors.grey[800],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_mainDecks[index]['name'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _showForm(_mainDecks[index]['id']),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeckDetail(
                                deckId: _mainDecks[index]['id'],
                                deckName: _mainDecks[index]['name'])),
                      );
                    }),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.grey[800],
        onPressed: () => _showForm(null),
      ),
    );
  }
}
