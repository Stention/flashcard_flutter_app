import 'package:flashcards_app/screens/deck_detail/components/subdecks/add_subdeck.dart';
import 'package:flashcards_app/screens/deck_detail/components/subdecks/update_subdeck.dart';
import 'package:flutter/material.dart';

void showSubDeckForm(int? id, dynamic context, List subDecks, String deckName,
    {required refreshDeck}) async {
  final TextEditingController _nameController = TextEditingController();

  if (id != null) {
    final existingDeck = subDecks.firstWhere((subdeck) => subdeck['id'] == id);
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
                      hintText: 'Subdeck name',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    child: Text(
                        id == null
                            ? 'Create new subdeck'
                            : 'Update the subdeck',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    onPressed: () async {
                      if (id == null) {
                        await addSubdeck(_nameController.text, deckName);
                        refreshDeck();
                      }
                      if (id != null) {
                        await updateSubdeck(id, _nameController.text);
                        refreshDeck();
                      }
                      _nameController.text = '';
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ));
}
