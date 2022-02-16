import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static const dictionary = """CREATE TABLE dictionary(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        name TEXT,
        numberOfWordsToLearn TINYINT NOT NULL DEFAULT 10,
        fromLanguage TEXT,
        toLanguage TEXT
      );
      """;
  static const subDictionary = """CREATE TABLE sub_dictionary(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        name TEXT,
        dictionary_id INTEGER NOT NULL,
        dictionary_name TEXT NOT NULL,
        FOREIGN KEY (dictionary_id) REFERENCES dictionary (id)
        FOREIGN KEY (dictionary_name) REFERENCES dictionary (name)  
      );
      """;
  static const wordPairs = """CREATE TABLE words_pairs(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         word TEXT NOT NULL,
         translation TEXT NOT NULL,
         level TINYINT NOT NULL DEFAULT 0,
         dictionary_id INTEGER NOT NULL,
         dictionary_name TEXT NOT NULL,
         sub_dictionary_id INTEGER,
         sub_dictionary_name TEXT,
         FOREIGN KEY (dictionary_id) REFERENCES dictionary (id)
         FOREIGN KEY (dictionary_name) REFERENCES dictionary (name)
         FOREIGN KEY (sub_dictionary_id) REFERENCES sub_dictionary (id)
         FOREIGN KEY (sub_dictionary_name) REFERENCES sub_dictionary (name)       
       );
       """;

  static Future<sql.Database> db() async {
    //await sql.deleteDatabase('demo_database.db');
    return sql.openDatabase(
      'demo_database.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await database.execute(dictionary);
        await database.execute(subDictionary);
        await database.execute(wordPairs);
      },
    );
  }

// dictionary
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

  static Future<int> updateDictionary(
      int id, String name, int numberOfWordsToLearn) async {
    final db = await DatabaseHelper.db();
    final data = {
      'name': name,
      'createdAt': DateTime.now().toString(),
      'numberOfWordsToLearn': numberOfWordsToLearn
    };
    final result =
        await db.update('dictionary', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteDictionary(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("dictionary", where: "id = ?", whereArgs: [id]);
      await db.query("sub_dictionary",
                  where: "dictionary_id = ?", whereArgs: [id]) ==
              []
          ? await db.delete("sub_dictionary",
              where: "dictionary_id = ?", whereArgs: [id])
          : null;
      await db.query("words_pairs",
                  where: "dictionary_id = ?", whereArgs: [id]) ==
              []
          ? await db.delete("words_pairs",
              where: "dictionary_id = ?", whereArgs: [id])
          : null;
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

// sub_dictionary
  static Future<int> createSubDictionary(
      String name, int dictionaryId, String dictionaryName) async {
    final db = await DatabaseHelper.db();
    final data = {
      'name': name,
      'dictionary_id': dictionaryId,
      'dictionary_name': dictionaryName
    };
    final id = await db.insert("sub_dictionary", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getSubDictionaries() async {
    final db = await DatabaseHelper.db();
    return db.query('sub_dictionary', orderBy: "id");
  }

  static Future<int> updateSubDictionary(int id, String name) async {
    final db = await DatabaseHelper.db();
    final data = {'name': name, 'createdAt': DateTime.now().toString()};
    final result = await db
        .update('sub_dictionary', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteSubDictionary(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("sub_dictionary", where: "id = ?", whereArgs: [id]);
      await db.query("words_pairs",
                  where: "sub_dictionary_id = ?", whereArgs: [id]) ==
              []
          ? await db.delete("words_pairs",
              where: "sub_dictionary_id = ?", whereArgs: [id])
          : null;
    } catch (err) {
      debugPrint("Something went wrong when deleting a sub_dictionary: $err");
    }
  }

// words
  static Future<int> createWord(String word, String translation,
      String dictionaryId, String dictionaryName,
      [subDictionaryName]) async {
    final db = await DatabaseHelper.db();
    final data = {
      'word': word,
      'translation': translation,
      'dictionary_id': dictionaryId,
      'dictionary_name': dictionaryName,
      'sub_dictionary_name': subDictionaryName
    };
    final id = await db.insert("words_pairs", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> updateWord(int id, String word, String translation,
      [subDictionaryName]) async {
    final db = await DatabaseHelper.db();
    final data = {
      'word': word,
      'translation': translation,
      'sub_dictionary_name': subDictionaryName
    };
    final result =
        await db.update("words_pairs", data, where: 'id=?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteWord(int id) async {
    final db = await DatabaseHelper.db();
    await db.delete("words_pairs", where: "id = ?", whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getWords(
      String dictionaryName) async {
    final db = await DatabaseHelper.db();
    return db.query('words_pairs',
        where: "dictionary_name = ?",
        whereArgs: [dictionaryName],
        orderBy: "id");
  }

  static Future<int> changeLevel(
      int id, int currentLevel, String answer) async {
    final db = await DatabaseHelper.db();

    if (answer == "correct") {
      while (0 <= currentLevel && currentLevel < 10) {
        var newLevel = currentLevel + 1;
        final data = {'level': newLevel};
        final result = await db
            .update('words_pairs', data, where: "id = ?", whereArgs: [id]);
        return result;
      }
    } else if (answer == "false") {
      while (0 < currentLevel && currentLevel <= 10) {
        var newLevel = currentLevel - 1;
        final data = {'level': newLevel};
        final result = await db
            .update('words_pairs', data, where: "id = ?", whereArgs: [id]);
        return result;
      }
    }
    return currentLevel;
  }
}
