import 'dart:convert';

import '../model/kaynaklar.dart';
import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class KaynaklarDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<Kaynaklar>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("Kaynaklar");
      return List.generate(result.length, (i) {
        return Kaynaklar.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<Kaynaklar>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("Kaynaklar", where: where);
    return List.generate(result.length, (i) {
      return Kaynaklar.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(Kaynaklar tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert(
          "Kaynaklar", {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });

    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from Kaynaklar");
    return true;
  }
}
