import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OrderDb {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'order.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
            create table orders (
              id integer primary key autoincrement,
              pd_code text not null,
              od_create text not null,
              od_price text not null,
              od_update text not null
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

  static Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await getDatabase();
    return db.insert('orders', order);
  }

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await getDatabase();
    return await db.query("orders");
  }

  static Future<int> deleteOrder(int id) async {
    final db = await getDatabase();
    return db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateOrder(int id, Map<String, dynamic> order) async {
    final db = await getDatabase();
    return db.update('orders', order, where: 'id = ?', whereArgs: [id]);
  }
}
