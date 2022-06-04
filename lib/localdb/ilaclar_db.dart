import 'dart:convert';

import '../model/ilaclar.dart';
import 'package:sqflite/sqflite.dart';
import 'create_database.dart';

class IlaclarDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<Ilaclar>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("Ilaclar");
      return List.generate(result.length, (i) {
        return Ilaclar.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<Ilaclar>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("Ilaclar", where: where);
    return List.generate(result.length, (i) {
      return Ilaclar.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(Ilaclar tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert(
          "Ilaclar", {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });
    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from Ilaclar");
    return true;
  }
}
