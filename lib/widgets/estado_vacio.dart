// Widget reutilizable: mensaje corto cuando una lista no tiene datos.
import 'package:flutter/material.dart';
import 'package:inventario_app/utils/colores.dart';

// Requisito: mostrar estados vacíos (componente reutilizable)
class EstadoVacio extends StatelessWidget {
  final String titulo;
  final String mensaje;
  // El botón es opcional: solo se muestra si llega texto y acción
  final String? textoBoton;
  final VoidCallback? alPresionar;

  const EstadoVacio({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoBoton,
    this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    // Solo texto: un título, una frase y, si hace falta, un botón
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'ZillaSlab',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colores.tinta,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colores.gris),
            ),
            if (textoBoton != null && alPresionar != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: alPresionar, child: Text(textoBoton!)),
            ],
          ],
        ),
      ),
    );
  }
}
