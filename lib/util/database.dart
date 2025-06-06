import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;

  // Nama database dan tabel
  static const String _databaseName = 'user_database.db';
  static const String _tableName = 'users';

  // Inisialisasi database
  Future<Database> _initDatabase() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Di dalam DatabaseHelper
  Future<bool> validateUser(String username, String password) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty && result[0]['password'] == password) {
      return true;
    }
    return false;
  }


  // Membuat tabel 'users'
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        password TEXT
      )
    ''');
  }

  // Menyimpan user baru
  Future<void> insertUser(String username, String email, String password) async {
    final db = await _initDatabase();
    await db.insert(
      _tableName,
      {'username': username, 'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Mengecek apakah username sudah terdaftar
  Future<bool> isUserExist(String username) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }
}
