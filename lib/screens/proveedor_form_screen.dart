// Formulario para crear un proveedor nuevo o editar uno existente.
import 'package:flutter/material.dart';
import 'package:inventario_app/models/proveedor.dart';
import 'package:inventario_app/services/proveedor_service.dart';
import 'package:inventario_app/widgets/campo_texto.dart';

class ProveedorFormScreen extends StatefulWidget {
  // Si proveedor es null se crea uno nuevo; si no, se edita
  final Proveedor? proveedor;

  const ProveedorFormScreen({super.key, this.proveedor});

  @override
  State<ProveedorFormScreen> createState() => _ProveedorFormScreenState();
}

class _ProveedorFormScreenState extends State<ProveedorFormScreen> {
  // Llave para validar todo el formulario de una vez
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();

  final ProveedorService _proveedorService = ProveedorService();

  @override
  void initState() {
    super.initState();
    // Si estamos editando, llenamos los campos con los datos actuales
    if (widget.proveedor != null) {
      _nombre.text = widget.proveedor!.nombre;
      _telefono.text = widget.proveedor!.telefono ?? '';
      _correo.text = widget.proveedor!.correo ?? '';
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    super.dispose();
  }

  // Requisito: validar el nombre (obligatorio)
  String? _validarNombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    return null;
  }

  // Requisito: validar el formato básico del correo, solo si se escribió
  String? _validarCorreo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }
    // texto + @ + texto + . + texto, sin espacios (ej: ventas@andina.com)
    final formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!formatoCorreo.hasMatch(valor.trim())) {
      return 'Escribe un correo válido (ej: nombre@correo.com)';
    }
    return null;
  }

  // Convierte un texto vacío en null para guardarlo así en la base de datos
  String? _textoONulo(String texto) {
    if (texto.trim().isEmpty) {
      return null;
    }
    return texto.trim();
  }

  // Requisito: guardar (crear o actualizar) solo si el formulario es válido
  Future<void> _guardar() async {
    // Oculta el teclado para que se vean bien los mensajes de error
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Proveedor proveedor = Proveedor(
      id: widget.proveedor?.id,
      nombre: _nombre.text.trim(),
      telefono: _textoONulo(_telefono.text),
      correo: _textoONulo(_correo.text),
    );

    if (widget.proveedor == null) {
      await _proveedorService.insertarProveedor(proveedor);
    } else {
      await _proveedorService.actualizarProveedor(proveedor);
    }

    if (!mounted) {
      return;
    }
    // Devolvemos true para que la lista sepa que debe recargarse
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.proveedor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar proveedor' : 'Nuevo proveedor'),
      ),
      // Ancho máximo de 700 para que se vea ordenado en tablets
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CampoTexto(
                    etiqueta: 'Nombre o razón social',
                    controller: _nombre,
                    validator: _validarNombre,
                  ),
                  CampoTexto(
                    etiqueta: 'Teléfono (opcional)',
                    controller: _telefono,
                    tipoTeclado: TextInputType.phone,
                  ),
                  CampoTexto(
                    etiqueta: 'Correo (opcional)',
                    controller: _correo,
                    validator: _validarCorreo,
                    tipoTeclado: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _guardar,
                    child: const Text('Guardar proveedor'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
