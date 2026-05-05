import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Place {
  final int? id;
  final String name;
  final String description;
  final String imagePath;
  final String date;

  const Place({
    this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'date': date,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imagePath: map['imagePath'],
      date: map['date'],
    );
  }
}

class DbHelper {
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'gezenti_local.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertPlace(Place place) async {
    Database db = await instance.database;
    return await db.insert(
      'Places',
      place.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Place>> getPlaces() async {
    Database db = await instance.database;
    var placesMap = await db.query('Places', orderBy: 'id DESC');
    return placesMap.map((e) => Place.fromMap(e)).toList();
  }

  Future<int> deletePlace(int id) async {
    Database db = await instance.database;
    return await db.delete('Places', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearPlaces() async {
    Database db = await instance.database;
    return await db.delete('Places');
  }
}
