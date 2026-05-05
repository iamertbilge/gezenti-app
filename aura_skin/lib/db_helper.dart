import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aura_skin.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Veritabanını oluşturuyoruz
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tablomuzu yaratıyoruz
    await db.execute('''
      CREATE TABLE rutin_tablosu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tamamlanan_gorev INTEGER,
        toplam_gorev INTEGER
      )
    ''');
    // Uygulama ilk açıldığında varsayılan değerleri atıyoruz
    await db.insert('rutin_tablosu', {'tamamlanan_gorev': 0, 'toplam_gorev': 4});
  }

  // Verileri okuma (Rutin başarı oranını hesaplamak için)
  Future<Map<String, dynamic>?> getRutinVerisi() async {
    final db = await instance.database;
    final maps = await db.query('rutin_tablosu', limit: 1);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // Görev tiklendikçe veritabanını güncelleme
  Future<void> goreviGuncelle(int yeniTamamlanan) async {
    final db = await instance.database;
    await db.update(
      'rutin_tablosu',
      {'tamamlanan_gorev': yeniTamamlanan},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}