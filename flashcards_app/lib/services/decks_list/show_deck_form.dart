import 'package:flashcards_app/services/decks_list/add_deck.dart';
import 'package:flashcards_app/services/decks_list/delete_deck.dart';
import 'package:flashcards_app/services/decks_list/update_deck.dart';
import 'package:flutter/material.dart';

void showDeckForm(int? id, dynamic context, List decks,
    {required refreshDeck}) {
  final TextEditingController _nameController = TextEditingController();

  if (id != null) {
    final existingDeck = decks.firstWhere((deck) => deck['id'] == id);
    _nameController.text = existingDeck['name'];
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Deck name',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
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
                              await addDeck(_nameController.text);
                              refreshDeck();
                            }
                            if (id != null) {
                              await updateDeck(id, _nameController.text);
                              refreshDeck();
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
                              await deleteDeck(id, context);
                              refreshDeck();
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
