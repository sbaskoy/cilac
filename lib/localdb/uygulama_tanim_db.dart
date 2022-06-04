import 'dart:convert';

import '../model/uygulamatanim.dart';
import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class UygulamaTanimDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<UygulamaTanim>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("UygulamaTanim");
      return List.generate(result.length, (i) {
        return UygulamaTanim.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<UygulamaTanim>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("UygulamaTanim", where: where);
    return List.generate(result.length, (i) {
      return UygulamaTanim.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(UygulamaTanim tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert("UygulamaTanim",
          {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });

    return result;
  }

  Future<int> delete() async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from UygulamaTanim");
    return result;
  }
}
