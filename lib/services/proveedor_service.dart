// Operaciones de base de datos (CRUD) para la tabla "proveedores".
import 'package:inventario_app/models/proveedor.dart';
import 'package:inventario_app/services/database_helper.dart';

class ProveedorService {
  // Requisito: consultar proveedores (Read)
  Future<List<Proveedor>> obtenerProveedores() async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    final filas = await db.query('proveedores', orderBy: 'nombre');

    List<Proveedor> proveedores = [];
    for (var fila in filas) {
      proveedores.add(Proveedor.fromMap(fila));
    }
    return proveedores;
  }

  // Requisito: registrar proveedores (Create)
  Future<int> insertarProveedor(Proveedor proveedor) async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    return await db.insert('proveedores', proveedor.toMap());
  }

  // Requisito: actualizar proveedores (Update)
  Future<int> actualizarProveedor(Proveedor proveedor) async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    return await db.update(
      'proveedores',
      proveedor.toMap(),
      where: 'id = ?',
      whereArgs: [proveedor.id],
    );
  }

  // Requisito: eliminar proveedores (Delete)
  Future<int> eliminarProveedor(int id) async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    return await db.delete('proveedores', where: 'id = ?', whereArgs: [id]);
  }

  // Requisito: total de proveedores para el dashboard
  Future<int> contarProveedores() async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM proveedores',
    );
    return resultado.first['total'] as int;
  }

  // Requisito: saber si el proveedor tiene productos antes de eliminarlo
  // (así no quedan productos huérfanos)
  Future<bool> tieneProductos(int id) async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM productos WHERE proveedor_id = ?',
      [id],
    );
    int total = resultado.first['total'] as int;
    return total > 0;
  }
}
