import 'dart:convert';

import '../model/ekipman.dart';
import 'package:sqflite/sqflite.dart';
import 'create_database.dart';

class EkipmanDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<Ekipman>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("Ekipman");
      return List.generate(result.length, (i) {
        return Ekipman.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<Ekipman>> getAllWithWhere(String where) async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("Ekipman", where: where);
      return List.generate(result.length, (i) {
        return Ekipman.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<int> insert(Ekipman tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert(
          "Ekipman", {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });
    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from Ekipman");
    return true;
  }
}
