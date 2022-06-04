import 'dart:convert';

import '../model/ilceler.dart';
import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class IlceDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<Ilce>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("Ilce");
      return List.generate(result.length, (i) {
        return Ilce.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<Ilce>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("Ilce");
    return List.generate(result.length, (i) {
      return Ilce.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(Ilce tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert(
          "Ilce", {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });

    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from Ilce");
    return true;
  }
}
