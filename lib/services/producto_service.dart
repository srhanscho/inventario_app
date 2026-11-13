// Operaciones de base de datos (CRUD) para la tabla "productos".
import 'package:inventario_app/models/producto.dart';
import 'package:inventario_app/services/database_helper.dart';

class ProductoService {
  // Requisito: consultar productos con el nombre del proveedor (INNER JOIN)
  // y filtrar por nombre con LIKE
  Future<List<Producto>> obtenerProductos({String busqueda = ''}) async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    final filas = await db.rawQuery(
      '''
      SELECT productos.*, proveedores.nombre AS nombre_proveedor
      FROM productos
      INNER JOIN proveedores ON productos.proveedor_id = proveedores.id
      WHERE productos.nombre LIKE ?
      ORDER BY productos.nombre
      ''',
      // Los % significan "cualquier texto antes y después"
      ['%$busqueda%'],
    );

    List<Producto> productos = [];
    for (var fila in filas) {
      productos.add(Producto.fromMap(fila));
    }
    return productos;
  }

  // Requisito: registrar productos asociados a un proveedor (Create)
  Future<int> insertarProducto(Producto producto) async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    return await db.insert('productos', producto.toMap());
  }

  // Requisito: actualizar productos (Update)
  Future<int> actualizarProducto(Producto producto) async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  // Requisito: eliminar productos (Delete)
  Future<int> eliminarProducto(int id) async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  // Requisito: total de productos para el dashboard
  Future<int> contarProductos() async {
    final db = await DatabaseHelper.obtenerBaseDeDatos();
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM productos',
    );
    return resultado.first['total'] as int;
  }
}
