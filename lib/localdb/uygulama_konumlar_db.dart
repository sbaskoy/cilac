import 'dart:convert';

import '../model/uygulama_konum.dart';
import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class UygulamaKonumlarDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<UygulamaKonumlar>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query(
        "UygulamaKonumlar",
      );
      return List.generate(result.length, (i) {
        var a = result[i]["json"];
        return UygulamaKonumlar.fromJson(jsonDecode(a));
      });
    });
  }

  Future<List<UygulamaKonumlar>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("UygulamaKonumlar", where: where);
    return List.generate(result.length, (i) {
      var a = result[i]["json"];
      return UygulamaKonumlar.fromJson(jsonDecode(a));
    });
  }

  Future<int> insert(UygulamaKonumlar tanim) async {
    Database db = await this.database;

    var result = await db.transaction((txn) async {
      return await txn.insert("UygulamaKonumlar",
          {"id": tanim.pUygulamaID, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });

    return result;
  }

  Future<int> update(UygulamaKonumlar tanim) async {
    Database db = await this.database;
    var result = await db.rawUpdate('''
    UPDATE UygulamaKonumlar 
    SET json = ? 
    WHERE id = ?
    ''', [jsonEncode(tanim.toJson()), tanim.pUygulamaID]);
    return result;
  }

  Future<int> delete() async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from UygulamaKonumlar");
    return result;
  }

  Future<int> deleteWithID(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from UygulamaKonumlar where id=$id");
    return result;
  }
}
