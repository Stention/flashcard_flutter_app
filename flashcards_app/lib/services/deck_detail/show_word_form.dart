import 'package:flashcards_app/services/deck_detail/words/add_word.dart';
import 'package:flashcards_app/services/deck_detail/words/delete_word.dart';
import 'package:flashcards_app/services/deck_detail/words/update_word.dart';
import 'package:flutter/material.dart';

void showWordForm(int? id, words, deckName, context,
    {required refreshDeck}) async {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();

  if (id != null) {
    final existingWord = words[words.indexWhere((w) => w['id'] == id)];
    _wordController.text = existingWord['word'];
    _translationController.text = existingWord['translation'];
  }
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height / 3,
              child: Column(
                children: [
                  TextField(
                    controller: _wordController,
                    decoration: const InputDecoration(
                      hintText: 'word',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _translationController,
                    decoration: const InputDecoration(
                      hintText: 'translation',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          child: Text(
                              id == null ? "Add a new word" : 'Update the word',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black)),
                          onPressed: () async {
                            if (id == null) {
                              await addWord(_wordController.text,
                                  _translationController.text, deckName);
                              refreshDeck();
                            }
                            if (id != null) {
                              await updateWord(id, _wordController.text,
                                  _translationController.text);
                              refreshDeck();
                            }
                            _wordController.text = '';
                            _translationController.text = '';
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          child: Text(id == null ? "Nix" : 'Delete the word',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          onPressed: () async {
                            if (id != null) {
                              await deleteWord(
                                  words[words.indexWhere((w) => w['id'] == id)]
                                      ['id']);
                              refreshDeck();
                            }
                            Navigator.of(context).pop();
                          },
                        )
                      ]),
                ],
              ),
            ),
          ));
}
