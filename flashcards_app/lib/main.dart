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
  List<Map<String, dynamic>> _decks = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();

  void _refreshDecks() async {
    final data = await DatabaseHelper.getDictionaries();
    setState(() {
      _decks = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingDeck = _decks.firstWhere((deck) => deck['id'] == id);
      _nameController.text = existingDeck['name'];
    }

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        builder: (_) => Container(
              padding: const EdgeInsets.all(15),
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
                        hintText: 'Name',
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      child: Text(id == null ? 'Create New' : 'Update',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black)),
                      onPressed: () async {
                        if (id == null) {
                          await _addDict();
                        }
                        if (id != null) {
                          await _updateDict(id);
                        }
                        _nameController.text = '';
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            ));
  }

  Future<void> _addDict() async {
    await DatabaseHelper.createDictionary(_nameController.text);
    _refreshDecks();
  }

  Future<void> _updateDict(int id) async {
    await DatabaseHelper.updateDictionary(id, _nameController.text);
    _refreshDecks();
  }

  void _deleteItem(int id) async {
    await DatabaseHelper.deleteDictionary(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a deck!'),
    ));
    _refreshDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Language Decks',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _decks.length,
              itemBuilder: (context, index) => Card(
                color: Colors.black,
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_decks[index]['name'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _showForm(_decks[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => _deleteItem(_decks[index]['id']),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeckDetail(
                                  deckId: _decks[index]['id'].toString(),
                                  deckName: _decks[index]['name'],
                                )),
                      );
                    }),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
        onPressed: () => _showForm(null),
      ),
    );
  }
}
