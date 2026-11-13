// Widget reutilizable: campo de formulario con su etiqueta arriba.
import 'package:flutter/material.dart';
import 'package:inventario_app/utils/colores.dart';

// Requisito: componente visual reutilizable (se usa en los dos formularios)
class CampoTexto extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType tipoTeclado;

  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.validator,
    this.tipoTeclado = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    // Primero la etiqueta y debajo el campo (los bordes vienen del tema)
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EtiquetaCampo(texto: etiqueta),
          TextFormField(
            controller: controller,
            keyboardType: tipoTeclado,
            validator: validator,
          ),
        ],
      ),
    );
  }
}

// Texto pequeño que va encima de cada campo (también lo usa el Dropdown)
class EtiquetaCampo extends StatelessWidget {
  final String texto;

  const EtiquetaCampo({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colores.tinta,
        ),
      ),
    );
  }
}
