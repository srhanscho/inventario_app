// Widget reutilizable: botón "⋯" con las opciones Editar y Eliminar.
import 'package:flutter/material.dart';
import 'package:inventario_app/utils/colores.dart';

class MenuOpciones extends StatelessWidget {
  final VoidCallback alEditar;
  final VoidCallback alEliminar;

  const MenuOpciones({
    super.key,
    required this.alEditar,
    required this.alEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones',
      icon: const Icon(Icons.more_horiz, color: Colores.gris),
      // Según la opción elegida llamamos a una función u otra
      onSelected: (opcion) {
        if (opcion == 'editar') {
          alEditar();
        } else {
          alEliminar();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'editar', child: Text('Editar')),
        PopupMenuItem(
          value: 'eliminar',
          child: Text('Eliminar', style: TextStyle(color: Colores.rojo)),
        ),
      ],
    );
  }
}
