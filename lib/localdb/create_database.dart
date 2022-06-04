import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static DatabaseHelper _instance;
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._init();
    return _instance;
  }

  Database database;
  DatabaseHelper._init();
  Future<void> loadDataBase() async {
    database = await initDatabase();
  }

  Future<Database> initDatabase() async {
    log("init dataabase");
    String dbPath = p.join(await getDatabasesPath(), "LocalDb.db");
    var notesDb = await openDatabase(dbPath, version: 1, onCreate: createDb);
    return notesDb;
  }
}

Future<Database> initializeDatabase() async {
  if (DatabaseHelper.instance.database == null) {
    await DatabaseHelper.instance.loadDataBase();
    return DatabaseHelper.instance.database;
  } else {
    return DatabaseHelper.instance.database;
  }
}

void createDb(Database db, int version) async {
  await db.execute("Create table IF NOT EXISTS Alanlar(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS Ekipman(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS HedefZararli(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS Ilaclar(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS Ilce(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS KaynakTurleri(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS Kaynaklar(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS UygulamaAlanlari(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS UygulamaKayit(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS UygulamaTanim(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS Yontemler(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS UygulamaKonumlar(id integer,json text,date text)");
  await db.execute("Create table IF NOT EXISTS Mahalle(id integer,json text,date text)");
}
