// Abre (o crea la primera vez) la base de datos SQLite de la app.
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Guardamos la base de datos aquí para abrirla una sola vez
  static Database? _baseDeDatos;

  // Devuelve la base de datos; si no existe todavía, la crea
  static Future<Database> obtenerBaseDeDatos() async {
    if (_baseDeDatos != null) {
      return _baseDeDatos!;
    }
    _baseDeDatos = await _crearBaseDeDatos();
    return _baseDeDatos!;
  }

  // Requisito: crear la base de datos SQLite desde la aplicación
  static Future<Database> _crearBaseDeDatos() async {
    // Ruta del archivo inventario.db dentro del teléfono
    String ruta = join(await getDatabasesPath(), 'inventario.db');

    return await openDatabase(
      ruta,
      version: 1,
      // Requisito: activar las claves foráneas (SQLite las trae apagadas)
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      // Requisito: definir las dos tablas relacionadas (solo la primera vez)
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE proveedores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            telefono TEXT,
            correo TEXT
          )
        ''');

        // Requisito: clave foránea proveedor_id -> proveedores(id), relación 1:N
        await db.execute('''
          CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            stock INTEGER NOT NULL,
            proveedor_id INTEGER NOT NULL,
            FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
          )
        ''');
      },
    );
  }
}
