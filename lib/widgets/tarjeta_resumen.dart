// Widget reutilizable: bloque de color del dashboard con un número grande.
import 'package:flutter/material.dart';

// Requisito: tarjetas de resumen con totales (componente reutilizable)
class TarjetaResumen extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final Color colorFondo;
  final Color colorTexto;

  const TarjetaResumen({
    super.key,
    required this.valor,
    required this.etiqueta,
    required this.colorFondo,
    required this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    // Un bloque de color sólido: el número arriba y la palabra debajo
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: TextStyle(
              fontFamily: 'PlexMono',
              fontSize: 34,
              fontWeight: FontWeight.w500,
              height: 1.1,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 4),
          Text(etiqueta, style: TextStyle(fontSize: 15, color: colorTexto)),
        ],
      ),
    );
  }
}
