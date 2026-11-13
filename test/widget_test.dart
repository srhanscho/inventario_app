// Pruebas sencillas que no usan la base de datos: formato y modelos.
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_app/models/producto.dart';
import 'package:inventario_app/models/proveedor.dart';
import 'package:inventario_app/utils/formato.dart';

void main() {
  test('formatearPrecio y fechaDeHoy dan el texto esperado', () {
    expect(formatearPrecio(12500), '\$ 12.500');
    expect(formatearPrecio(1500000), '\$ 1.500.000');
    // fechaDeHoy también acepta una fecha fija
    expect(fechaDeHoy(DateTime(2026, 11, 10)), 'Martes, 10 de noviembre');
  });

  test('Proveedor se convierte a Map y vuelve igual', () {
    Proveedor original = Proveedor(
      id: 1,
      nombre: 'Distribuidora Andina',
      telefono: '3001234567',
      correo: 'ventas@andina.com',
    );

    Proveedor copia = Proveedor.fromMap(original.toMap());

    expect(copia.id, 1);
    expect(copia.nombre, 'Distribuidora Andina');
    expect(copia.telefono, '3001234567');
    expect(copia.correo, 'ventas@andina.com');
  });

  test('Producto.fromMap lee el nombre del proveedor del JOIN', () {
    Producto producto = Producto.fromMap({
      'id': 1,
      'nombre': 'Leche Entera 1L',
      'precio': 4200.0,
      'stock': 3,
      'proveedor_id': 2,
      'nombre_proveedor': 'Lacteos del Norte',
    });

    expect(producto.nombreProveedor, 'Lacteos del Norte');
    expect(producto.precio, 4200.0);
    expect(producto.toMap().containsKey('nombre_proveedor'), false);
    // Con 3 unidades el stock es bajo
    expect(producto.stockBajo, true);
  });
}
