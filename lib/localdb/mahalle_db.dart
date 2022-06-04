import 'dart:convert';

import 'package:cilac/model/mahalle_model.dart';
import 'package:sqflite/sqflite.dart';
import 'create_database.dart';

class MahalleDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<MahalleModel>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("Mahalle");
      return List.generate(result.length, (i) {
        return MahalleModel.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<MahalleModel>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("Mahalle", where: where);
    return List.generate(result.length, (i) {
      return MahalleModel.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(MahalleModel tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert(
          "Mahalle", {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });

    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from Mahalle");
    return true;
  }
}
