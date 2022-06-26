import "package:flutter/material.dart";
import "database_helper.dart";

class FilterWords extends StatefulWidget {
  final int deckId;
  final String deckName;

  const FilterWords({Key? key, required this.deckId, required this.deckName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FilterWordsState();
  }
}

class _FilterWordsState extends State<FilterWords> {
  List<Map<String, dynamic>> _allWords = [];
  List<Map<String, dynamic>> _foundWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshDecks();
  }

  void _refreshDecks() async {
    final data = await DatabaseHelper.getWords(widget.deckName);
    setState(() {
      _allWords = data;
      _isLoading = false;
    });
  }

  void _runFilter(String keyword) {
    List<Map<String, dynamic>> results = [];
    if (keyword.isEmpty) {
      results = _allWords;
    } else {
      results = _allWords
          .where((word) =>
              word["word"].toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundWords = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("Search for a word",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      onChanged: (value) => _runFilter(value),
                      decoration: const InputDecoration(
                          labelText: 'Search', suffixIcon: Icon(Icons.search)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: _foundWords.isNotEmpty
                          ? ListView.builder(
                              itemCount: _foundWords.length,
                              itemBuilder: (context, index) => Card(
                                    key: ValueKey(_foundWords[index]["id"]),
                                    color: Colors.amberAccent,
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListTile(
                                      leading: Text(
                                        _foundWords[index]["word"].toString(),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      title: Text(
                                          _foundWords[index]['translation']),
                                      subtitle: const Text(
                                        '_________',
                                      ),
                                    ),
                                  ))
                          : ListView.builder(
                              itemCount: _allWords.length,
                              itemBuilder: (context, index) => Card(
                                    key: ValueKey(_allWords[index]["id"]),
                                    color: Colors.amberAccent,
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListTile(
                                      leading: Text(
                                        _allWords[index]["word"].toString(),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      title:
                                          Text(_allWords[index]['translation']),
                                    ),
                                  )),
                    ),
                  ],
                ),
              ));
  }
}
