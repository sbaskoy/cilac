import 'dart:convert';

import '../model/kaynakturleri.dart';
import 'package:sqflite/sqflite.dart';

import 'create_database.dart';

class KaynakTurleriDb {
  static Database _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<List<KaynakTurleri>> getAll() async {
    Database db = await this.database;
    return await db.transaction((txn) async {
      var result = await txn.query("KaynakTurleri");
      return List.generate(result.length, (i) {
        return KaynakTurleri.fromJson(jsonDecode(result[i]["json"]));
      });
    });
  }

  Future<List<KaynakTurleri>> getAllWithWhere(String where) async {
    Database db = await this.database;
    var result = await db.query("KaynakTurleri", where: where);
    return List.generate(result.length, (i) {
      return KaynakTurleri.fromJson(jsonDecode(result[i]["json"]));
    });
  }

  Future<int> insert(KaynakTurleri tanim) async {
    Database db = await this.database;
    var result = await db.transaction((txn) async {
      return await txn.insert("KaynakTurleri",
          {"id": tanim.id, "json": jsonEncode(tanim.toJson()), "date": DateTime.now().toIso8601String()});
    });

    return result;
  }

  Future<bool> delete() async {
    Database db = await this.database;
    await db.rawDelete("delete from KaynakTurleri");
    return true;
  }
}
