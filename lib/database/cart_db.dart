import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CartDb {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cart.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          create table carts (
            id integer primary key autoincrement,
            pd_code text,
            name text,
            count text,
            price text,
            image_path text
          )
        ''');
      },
    );

    return _database!;
  }

  static Future<List<Map<String, dynamic>>> query(String command) async {
    final db = await getDatabase();
    return db.rawQuery(command);
  }

  static Future<int> insert(Map<String, dynamic> data) async {
    final db = await getDatabase();
    return db.insert('carts', data);
  }
}
