import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static const dictionary = """CREATE TABLE dictionary(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        name TEXT
      );
      """;
  static const wordPairs = """CREATE TABLE words_pairs(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         dictionary_name TEXT NOT NULL,
         sub_dictionary_name TEXT,
         word TEXT NOT NULL,
         translation TEXT NOT NULL,
         FOREIGN KEY (dictionary_name) REFERENCES dictionary (name)
       );
       """;

  static Future<sql.Database> db() async {
    // await sql.deleteDatabase('demo_database.db');
    return sql.openDatabase(
      'demo_database.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await database.execute(dictionary);
        await database.execute(wordPairs);
      },
    );
  }

  static Future<int> createDictionary(String name) async {
    final db = await DatabaseHelper.db();
    final data = {'name': name};
    final id = await db.insert("dictionary", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getDictionaries() async {
    final db = await DatabaseHelper.db();
    return db.query('dictionary', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getDictionary(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('dictionary', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateDictionary(int id, String name) async {
    final db = await DatabaseHelper.db();
    final data = {'name': name, 'createdAt': DateTime.now().toString()};
    final result =
        await db.update('dictionary', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteDictionary(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("dictionary", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<int> createWord(
      String dictionaryName, String word, String translation) async {
    final db = await DatabaseHelper.db();
    final data = {
      'dictionary_name': dictionaryName,
      'word': word,
      'translation': translation
    };
    final id = await db.insert("words_pairs", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getWords(
      String dictionaryName) async {
    final db = await DatabaseHelper.db();
    return db.query('words_pairs',
        where: "dictionary_name = ?",
        whereArgs: [dictionaryName],
        orderBy: "id");
  }
}
