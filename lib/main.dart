// Punto de entrada de la app: configura el tema (colores y letras) y las rutas.
import 'package:flutter/material.dart';
import 'package:inventario_app/routes/app_routes.dart';
import 'package:inventario_app/utils/colores.dart';

void main() {
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Borde fino de 1 px que usan las tarjetas y los campos
    const bordeFino = BorderSide(color: Colores.borde);

    return MaterialApp(
      title: 'Inventario',
      debugShowCheckedModeBanner: false,
      // Requisito: paleta de colores coherente en toda la app
      theme: ThemeData(
        useMaterial3: true,
        // Letra de toda la app (declarada en pubspec.yaml)
        fontFamily: 'PlexSans',
        // Colores base tomados de lib/utils/colores.dart
        colorScheme: const ColorScheme.light(
          primary: Colores.verde,
          onPrimary: Colors.white,
          secondary: Colores.amarillo,
          onSecondary: Colores.tinta,
          error: Colores.rojo,
          surface: Colors.white,
          onSurface: Colores.tinta,
          outline: Colores.borde,
          outlineVariant: Colores.borde,
        ),
        scaffoldBackgroundColor: Colores.fondo,
        // Líneas divisorias finas y claras
        dividerTheme: const DividerThemeData(
          color: Colores.borde,
          thickness: 1,
          space: 1,
        ),

        // Barra superior: mismo color del fondo, título a la izquierda
        // y una línea fina abajo en lugar de sombra
        appBarTheme: const AppBarTheme(
          backgroundColor: Colores.fondo,
          foregroundColor: Colores.tinta,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          shape: Border(bottom: bordeFino),
          titleTextStyle: TextStyle(
            fontFamily: 'ZillaSlab',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colores.tinta,
          ),
        ),

        // Tarjetas blancas, planas, con borde fino y sin sombra
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: bordeFino,
          ),
        ),

        // Campos de texto: fondo blanco, borde fino y verde al escribir
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          hintStyle: const TextStyle(color: Colores.gris),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: bordeFino,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colores.verde, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colores.rojo),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colores.rojo, width: 1.5),
          ),
        ),

        // Botón principal: ancho completo, verde y sin sombra
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colores.verde,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            textStyle: const TextStyle(
              fontFamily: 'PlexSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Mensajes de abajo (SnackBar): flotantes y con esquinas suaves
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        // Ventanas de confirmación y menú de opciones: planos y blancos
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          titleTextStyle: const TextStyle(
            fontFamily: 'ZillaSlab',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colores.tinta,
          ),
          contentTextStyle: const TextStyle(
            fontFamily: 'PlexSans',
            fontSize: 15,
            color: Colores.gris,
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: bordeFino,
          ),
        ),
      ),
      // Requisito: navegación con una configuración de rutas
      initialRoute: AppRoutes.inicio,
      routes: AppRoutes.rutas,
    );
  }
}
