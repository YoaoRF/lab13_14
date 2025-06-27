import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'trabajador.dart';

class TrabajadorDatabase {
  // ✅ SINGLETON PATTERN - Solo una instancia
  static final TrabajadorDatabase _instance = TrabajadorDatabase._internal();
  static TrabajadorDatabase get instance => _instance;
  
  static Database? _database;

  // ✅ Constructor privado para Singleton
  TrabajadorDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'trabajadores.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, _) async {
    return await db.execute('''
        CREATE TABLE ${TrabajadorFields.tableName} (
          ${TrabajadorFields.id} ${TrabajadorFields.idType},
          ${TrabajadorFields.nombres} ${TrabajadorFields.textType},
          ${TrabajadorFields.apellidos} ${TrabajadorFields.textType},
          ${TrabajadorFields.fechaNacimiento} ${TrabajadorFields.textType},
          ${TrabajadorFields.sueldo} ${TrabajadorFields.realType},
          ${TrabajadorFields.createdTime} ${TrabajadorFields.textType}
        )
      ''');
  }

  // CRUD Operations
  Future<TrabajadorModel> create(TrabajadorModel trabajador) async {
    final db = await instance.database;
    final id = await db.insert(TrabajadorFields.tableName, trabajador.toJson());
    return trabajador.copy(id: id);
  }

  Future<TrabajadorModel> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      TrabajadorFields.tableName,
      columns: TrabajadorFields.values,
      where: '${TrabajadorFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TrabajadorModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<TrabajadorModel>> readAll() async {
    final db = await instance.database;
    const orderBy = '${TrabajadorFields.apellidos} ASC';
    final result = await db.query(TrabajadorFields.tableName, orderBy: orderBy);
    return result.map((json) => TrabajadorModel.fromJson(json)).toList();
  }

  Future<List<TrabajadorModel>> readByEdad(int edadMinima) async {
    final db = await instance.database;
    final result = await db.query(TrabajadorFields.tableName);
    final trabajadores = result.map((json) => TrabajadorModel.fromJson(json)).toList();
    return trabajadores.where((trabajador) => trabajador.edad >= edadMinima).toList();
  }

  Future<List<TrabajadorModel>> readBySueldo(double sueldoMinimo) async {
    final db = await instance.database;
    final result = await db.query(
      TrabajadorFields.tableName,
      where: '${TrabajadorFields.sueldo} >= ?',
      whereArgs: [sueldoMinimo],
      orderBy: '${TrabajadorFields.sueldo} DESC',
    );
    return result.map((json) => TrabajadorModel.fromJson(json)).toList();
  }

  Future<int> update(TrabajadorModel trabajador) async {
    final db = await instance.database;
    return db.update(
      TrabajadorFields.tableName,
      trabajador.toJson(),
      where: '${TrabajadorFields.id} = ?',
      whereArgs: [trabajador.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      TrabajadorFields.tableName,
      where: '${TrabajadorFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}