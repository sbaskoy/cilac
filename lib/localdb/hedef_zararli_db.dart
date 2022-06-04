import 'dart:convert';

import '../model/hedefzararli.dart';
import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class HedefZararliDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<HedefZararli>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("HedefZararli");
      return List.generate(result.length, (i) {
        return HedefZararli.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<HedefZararli>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("HedefZararli", where: where);
    return List.generate(result.length, (i) {
      return HedefZararli.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(HedefZararli tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert("HedefZararli",
          {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });
    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from HedefZararli");
    return true;
  }
}
