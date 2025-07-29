import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProductDb {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'product.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
            create table products (
              id integer primary key autoincrement,
              barcode text,
              pd_code text not null,
              pd_stock text not  null,
              name text not null,
              price real not null,
              category text,
              description text,
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

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await getDatabase();
    return db.insert('products', product);
  }

  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await getDatabase();
    return await db.query("products");
  }

  static Future<int> deleteProdcut(int id) async {
    final db = await getDatabase();
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await getDatabase();
    return db.update('products', product, where: 'id = ?', whereArgs: [id]);
  }
}
