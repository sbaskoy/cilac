import 'dart:convert';

import '../model/uygulamaalanlari.dart';
import 'package:sqflite/sqflite.dart';
import 'create_database.dart';

class UygulamaAlanlariDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<UygulamaAlanlari>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("UygulamaAlanlari");
      return List.generate(result.length, (i) {
        return UygulamaAlanlari.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<UygulamaAlanlari>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("UygulamaAlanlari", where: where);
    return List.generate(result.length, (i) {
      return UygulamaAlanlari.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(UygulamaAlanlari tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert("UygulamaAlanlari",
          {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });
    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from UygulamaAlanlari");
    return true;
  }
}
