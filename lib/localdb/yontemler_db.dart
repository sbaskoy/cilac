import 'dart:convert';

import '../model/yontemler.dart';
import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class YontemlerDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<Yontemler>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("Yontemler");
      return List.generate(result.length, (i) {
        return Yontemler.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<Yontemler>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("Yontemler", where: where);
    return List.generate(result.length, (i) {
      return Yontemler.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(Yontemler tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert(
          "Yontemler", {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });

    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from Yontemler");
    return true;
  }
}
