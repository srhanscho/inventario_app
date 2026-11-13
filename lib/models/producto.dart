// Modelo Producto: representa una fila de la tabla "productos".
class Producto {
  int? id;
  String nombre;
  double precio;
  int stock;
  int proveedorId;
  // No es una columna: llega desde el INNER JOIN con proveedores
  String? nombreProveedor;

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.proveedorId,
    this.nombreProveedor,
  });

  // true si quedan menos de 5 unidades (puedes cambiar el 5)
  bool get stockBajo {
    return stock < 5;
  }

  // Convierte el objeto en un Map para guardarlo en SQLite
  // (sin nombreProveedor, porque esa columna no existe en la tabla)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'stock': stock,
      'proveedor_id': proveedorId,
    };
  }

  // Crea un Producto a partir de una fila leída de SQLite
  factory Producto.fromMap(Map<String, dynamic> mapa) {
    return Producto(
      id: mapa['id'],
      nombre: mapa['nombre'],
      // "num" acepta int o double; lo pasamos a double
      precio: (mapa['precio'] as num).toDouble(),
      stock: mapa['stock'],
      proveedorId: mapa['proveedor_id'],
      // Solo existe si la consulta hizo el JOIN
      nombreProveedor: mapa['nombre_proveedor'],
    );
  }
}
