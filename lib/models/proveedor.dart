// Modelo Proveedor: representa una fila de la tabla "proveedores".
class Proveedor {
  int? id;
  String nombre;
  String? telefono;
  String? correo;

  Proveedor({this.id, required this.nombre, this.telefono, this.correo});

  // Convierte el objeto en un Map para guardarlo en SQLite
  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'telefono': telefono, 'correo': correo};
  }

  // Crea un Proveedor a partir de una fila leída de SQLite
  factory Proveedor.fromMap(Map<String, dynamic> mapa) {
    return Proveedor(
      id: mapa['id'],
      nombre: mapa['nombre'],
      telefono: mapa['telefono'],
      correo: mapa['correo'],
    );
  }
}
