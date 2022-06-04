import 'dart:convert';

import '../model/uygulamakayit.dart';
import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class UygulamaKayitDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<UygulamaKayit>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("UygulamaKayit");
      return List.generate(result.length, (i) {
        return UygulamaKayit.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<UygulamaKayit>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("UygulamaKayit", where: where);
    return List.generate(result.length, (i) {
      return UygulamaKayit.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(UygulamaKayit tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert("UygulamaKayit",
          {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });
    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from UygulamaKayit");
    return true;
  }

  Future<int> deleteWithID(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from UygulamaKayit where id=$id");
    return result;
  }
}
