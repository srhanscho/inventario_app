// Rutas con nombre de la app: cada nombre abre una pantalla.
import 'package:flutter/material.dart';
import 'package:inventario_app/screens/inicio_screen.dart';
import 'package:inventario_app/screens/productos_screen.dart';
import 'package:inventario_app/screens/proveedores_screen.dart';

class AppRoutes {
  static const String inicio = '/';
  static const String productos = '/productos';
  static const String proveedores = '/proveedores';

  // Requisito: navegación entre pantallas con rutas
  static Map<String, WidgetBuilder> rutas = {
    inicio: (context) => const InicioScreen(),
    productos: (context) => const ProductosScreen(),
    proveedores: (context) => const ProveedoresScreen(),
  };
}
