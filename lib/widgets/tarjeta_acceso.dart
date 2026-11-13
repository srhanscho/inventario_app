// Widget reutilizable: fila de texto que se toca para abrir una sección.
import 'package:flutter/material.dart';
import 'package:inventario_app/utils/colores.dart';

// Requisito: accesos visibles a las secciones (componente reutilizable)
class TarjetaAcceso extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const TarjetaAcceso({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // InkWell hace que toda la fila se pueda tocar
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colores.tinta,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(fontSize: 13, color: Colores.gris),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colores.gris),
          ],
        ),
      ),
    );
  }
}
