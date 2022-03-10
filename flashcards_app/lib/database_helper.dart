import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static const dictionary = """CREATE TABLE dictionary(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        name TEXT UNIQUE,
        numberOfWordsToLearn TINYINT NOT NULL DEFAULT 10,
        targetLanguage TEXT
      );
      """;
  static const subDictionary = """CREATE TABLE sub_dictionary(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        name TEXT UNIQUE,
        dictionary_name TEXT NOT NULL,
        FOREIGN KEY ("dictionary_name") REFERENCES "dictionary" ("name") ON UPDATE CASCADE ON DELETE CASCADE  
      );
      """;
  static const wordPairs = """CREATE TABLE words_pairs(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         word TEXT NOT NULL,
         translation TEXT NOT NULL,
         level TINYINT NOT NULL DEFAULT 0,
         dictionary_name TEXT NOT NULL,
         sub_dictionary_name TEXT DEFAULT NULL,
         FOREIGN KEY ("dictionary_name") REFERENCES "dictionary" ("name") ON UPDATE CASCADE ON DELETE CASCADE 
         FOREIGN KEY ("sub_dictionary_name") REFERENCES "sub_dictionary" ("name") ON UPDATE CASCADE ON DELETE CASCADE      
       );
       """;

  static Future<sql.Database> db() async {
    //await sql.deleteDatabase('demo_database.db');
    return sql.openDatabase('demo_database.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await database.execute(dictionary);
      await database.execute(subDictionary);
      await database.execute(wordPairs);
    }, onConfigure: (sql.Database database) async {
      await database.execute('PRAGMA foreign_keys=ON');
    });
  }

// dictionary
  static Future<int> createDeck(String deckName) async {
    final db = await DatabaseHelper.db();
    final data = {'name': deckName, 'createdAt': DateTime.now().toString()};
    final id = await db.insert('dictionary', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> updateDeck(int id, String name) async {
    final db = await DatabaseHelper.db();
    final result = db.update(
        'dictionary',
        {
          'name': name,
        },
        where: 'id=?',
        whereArgs: [id]);
    return result;
  }

  static Future<int> updateDeckWordsCount(
      int id, int numberOfWordsToLearn) async {
    final db = await DatabaseHelper.db();
    final result = await db.update(
        'dictionary',
        {
          'numberOfWordsToLearn': numberOfWordsToLearn,
        },
        where: 'id=?',
        whereArgs: [id]);
    return result;
  }

  static Future<int> updateDeckTargetLanguage(
      int id, String targetLanguage) async {
    final db = await DatabaseHelper.db();
    final result = await db.update(
        'dictionary', {'targetLanguage': targetLanguage},
        where: 'id=?', whereArgs: [id]);
    return result;
  }

  static Future<List<Map<String, dynamic>>> getDecks(int? id) async {
    final db = await DatabaseHelper.db();
    if (id == null) {
      return db.query('dictionary', orderBy: 'id');
    } else {
      return db.query('dictionary', where: 'id=?', whereArgs: [id], limit: 1);
    }
  }

  static Future<void> deleteDeck(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete('dictionary', where: 'id=?', whereArgs: [id]);
    } catch (err) {
      debugPrint('Something went wrong when deleting an item: $err');
    }
  }

// sub_dictionary
  static Future<int> createSubDeck(String name, String deckName) async {
    final db = await DatabaseHelper.db();
    final data = {
      'name': name,
      'createdAt': DateTime.now().toString(),
      'dictionary_name': deckName
    };
    final id = await db.insert('sub_dictionary', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> updateSubDeck(int id, String name) async {
    final db = await DatabaseHelper.db();
    final result = await db.update('sub_dictionary', {'name': name},
        where: 'id=?', whereArgs: [id]);
    return result;
  }

  static Future<List<Map<String, dynamic>>> getSubDecks(String deckName) async {
    final db = await DatabaseHelper.db();
    return db.query('sub_dictionary',
        where: 'dictionary_name=?', whereArgs: [deckName], orderBy: 'id');
  }

  static Future<void> deleteSubDeck(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete('sub_dictionary', where: 'id=?', whereArgs: [id]);
    } catch (err) {
      debugPrint('Something went wrong when deleting a sub_dictionary: $err');
    }
  }

// words
  static Future<int> createWord(
      String word, String translation, String dictionaryName) async {
    final db = await DatabaseHelper.db();
    final data = {
      'word': word,
      'translation': translation,
      'dictionary_name': dictionaryName,
    };
    final id = await db.insert('words_pairs', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> updateWord(int id, String word, String translation) async {
    final db = await DatabaseHelper.db();
    final data = {
      'word': word,
      'translation': translation,
    };
    final result =
        await db.update('words_pairs', data, where: 'id=?', whereArgs: [id]);
    return result;
  }

  static Future<int> updateWordsSubdeck(int id, String? subdeckName) async {
    final db = await DatabaseHelper.db();
    final data = {'sub_dictionary_name': subdeckName};
    final result =
        await db.update('words_pairs', data, where: 'id=?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteWord(int id) async {
    final db = await DatabaseHelper.db();
    await db.delete('words_pairs', where: 'id=?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getWords(
      String dictionaryName) async {
    final db = await DatabaseHelper.db();
    return db.query('words_pairs',
        where: 'dictionary_name=?', whereArgs: [dictionaryName], orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getWordsWithoutSubdeck(
      String dictionaryName) async {
    final db = await DatabaseHelper.db();
    return db.query('words_pairs',
        where:
            'dictionary_name = ? and (sub_dictionary_name is NULL)', // or sub_dictionary_name = "")',
        whereArgs: [dictionaryName],
        orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getWordsInSubdeck(
      String subDictionaryName) async {
    final db = await DatabaseHelper.db();
    return db.query('words_pairs',
        where: 'sub_dictionary_name=?',
        whereArgs: [subDictionaryName],
        orderBy: 'id');
  }

  static Future<int> changeLevel(
      int id, int currentLevel, String answer) async {
    final db = await DatabaseHelper.db();
    if (answer == 'correct') {
      while (0 <= currentLevel && currentLevel < 10) {
        final result = await db.update(
            'words_pairs', {'level': currentLevel + 1},
            where: 'id=?', whereArgs: [id]);
        return result;
      }
    } else if (answer == 'false') {
      while (0 < currentLevel && currentLevel <= 10) {
        final result = await db.update(
            'words_pairs', {'level': currentLevel - 1},
            where: 'id=?', whereArgs: [id]);
        return result;
      }
    }
    return currentLevel;
  }
}
