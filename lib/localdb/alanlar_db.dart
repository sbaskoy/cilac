import 'dart:convert';

import '../model/alanlar.dart';

import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class AlanlarDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<Alanlar>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query(
        "Alanlar",
      );
      return List.generate(result.length, (i) {
        var a = result[i]["json"];
        return Alanlar.fromJson(jsonDecode(a));
      });
    });
  }

  Future<List<Alanlar>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("Alanlar", where: where);
    return List.generate(result.length, (i) {
      var a = result[i]["json"];
      return Alanlar.fromJson(jsonDecode(a));
    });
  }

  Future<int> insert(Alanlar tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert(
          "Alanlar", {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });

    return result;
  }

  Future<int> delete() async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from Alanlar");
    return result;
  }
}
