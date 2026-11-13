// Widget reutilizable: el precio como una etiqueta amarilla de tienda.
import 'package:flutter/material.dart';
import 'package:inventario_app/utils/colores.dart';
import 'package:inventario_app/utils/formato.dart';

class EtiquetaPrecio extends StatelessWidget {
  final double precio;

  const EtiquetaPrecio({super.key, required this.precio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colores.amarillo,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        // La etiqueta ocupa solo el ancho de su contenido
        mainAxisSize: MainAxisSize.min,
        children: [
          // El "huequito" de la etiqueta colgante
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colores.tinta,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatearPrecio(precio),
            style: const TextStyle(
              fontFamily: 'PlexMono',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colores.tinta,
            ),
          ),
        ],
      ),
    );
  }
}
