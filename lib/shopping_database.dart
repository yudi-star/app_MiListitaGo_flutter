import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'shopping_item.dart';

class ShoppingDatabase {
  // Singleton - solo una instancia de la base de datos
  static final ShoppingDatabase instance = ShoppingDatabase._internal();
  static Database? _database;

  ShoppingDatabase._internal();

  // Obtiene la base de datos
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'shopping_list.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // Crea la tabla en la base de datos
  Future<void> _createDatabase(Database db, _) async {
    return await db.execute('''
      CREATE TABLE ${ShoppingItemFields.tableName} (
        ${ShoppingItemFields.id} ${ShoppingItemFields.idType},
        ${ShoppingItemFields.name} ${ShoppingItemFields.textType},
        ${ShoppingItemFields.quantity} ${ShoppingItemFields.intType},
        ${ShoppingItemFields.category} ${ShoppingItemFields.textType},
        ${ShoppingItemFields.isPurchased} ${ShoppingItemFields.intType},
        ${ShoppingItemFields.createdTime} ${ShoppingItemFields.textType}
      )
    ''');
  }

  // CREATE - Crear un nuevo item
  Future<ShoppingItem> create(ShoppingItem item) async {
    final db = await instance.database;
    final id =
        await db.insert(ShoppingItemFields.tableName, item.toJson());
    return item.copy(id: id);
  }

  // READ - Leer un item por ID
  Future<ShoppingItem> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      ShoppingItemFields.tableName,
      columns: ShoppingItemFields.values,
      where: '${ShoppingItemFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ShoppingItem.fromJson(maps.first);
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  // READ ALL - Leer todos los items
  Future<List<ShoppingItem>> readAll() async {
    final db = await instance.database;
    const orderBy = '${ShoppingItemFields.createdTime} DESC';
    final result = await db.query(
      ShoppingItemFields.tableName,
      orderBy: orderBy,
    );

    return result.map((json) => ShoppingItem.fromJson(json)).toList();
  }

  // UPDATE - Actualizar un item
  Future<int> update(ShoppingItem item) async {
    final db = await instance.database;
    return db.update(
      ShoppingItemFields.tableName,
      item.toJson(),
      where: '${ShoppingItemFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  // DELETE - Eliminar un item
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      ShoppingItemFields.tableName,
      where: '${ShoppingItemFields.id} = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Eliminar todos los items marcados como comprados
  Future<int> deletePurchasedAll() async {
    final db = await instance.database;
    return await db.delete(
      ShoppingItemFields.tableName,
      where: '${ShoppingItemFields.isPurchased} = ?',
      whereArgs: [1],
    );
  }

  // Cierra la base de datos
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}