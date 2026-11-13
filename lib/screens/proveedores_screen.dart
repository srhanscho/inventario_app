// Pantalla con el listado de proveedores: crear, editar y eliminar.
import 'package:flutter/material.dart';
import 'package:inventario_app/models/proveedor.dart';
import 'package:inventario_app/screens/proveedor_form_screen.dart';
import 'package:inventario_app/services/proveedor_service.dart';
import 'package:inventario_app/utils/colores.dart';
import 'package:inventario_app/widgets/estado_vacio.dart';
import 'package:inventario_app/widgets/menu_opciones.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final ProveedorService _proveedorService = ProveedorService();
  late Future<List<Proveedor>> _futuroProveedores;

  @override
  void initState() {
    super.initState();
    _futuroProveedores = _proveedorService.obtenerProveedores();
  }

  // Vuelve a consultar la base de datos y redibuja la lista
  void _cargarProveedores() {
    setState(() {
      _futuroProveedores = _proveedorService.obtenerProveedores();
    });
  }

  // Abre el formulario (vacío para crear, con datos para editar)
  Future<void> _abrirFormulario(Proveedor? proveedor) async {
    final guardado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProveedorFormScreen(proveedor: proveedor),
      ),
    );
    // Requisito: mensaje de confirmación al guardar
    if (guardado == true) {
      _mostrarMensaje('Proveedor guardado');
      _cargarProveedores();
    }
  }

  // Requisito: eliminar respetando la integridad referencial
  Future<void> _eliminarProveedor(Proveedor proveedor) async {
    // Si tiene productos no se elimina, para no dejar productos huérfanos
    if (await _proveedorService.tieneProductos(proveedor.id!)) {
      _mostrarMensaje(
        'No puedes eliminar este proveedor: todavía tiene productos. '
        'Cámbialos de proveedor o elimínalos primero.',
        esError: true,
      );
      return;
    }
    if (!mounted) {
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar «${proveedor.nombre}»?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colores.rojo),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true) {
      return;
    }
    await _proveedorService.eliminarProveedor(proveedor.id!);
    _mostrarMensaje('Proveedor eliminado');
    _cargarProveedores();
  }

  // SnackBar verde para éxito y rojo para errores
  void _mostrarMensaje(String texto, {bool esError = false}) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colores.rojo : Colores.tinta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores')),
      // Botón fijo abajo, fácil de alcanzar con el pulgar
      bottomNavigationBar: _construirBotonAgregar(),
      // Ancho máximo de 700 para que se vea ordenado en tablets
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _construirLista(),
        ),
      ),
    );
  }

  Widget _construirBotonAgregar() {
    return SafeArea(
      child: Center(
        // heightFactor: 1 evita que ocupe toda la pantalla hacia arriba
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                _abrirFormulario(null);
              },
              child: const Text('Agregar proveedor'),
            ),
          ),
        ),
      ),
    );
  }

  // Requisito: listado de proveedores con FutureBuilder
  Widget _construirLista() {
    return FutureBuilder<List<Proveedor>>(
      future: _futuroProveedores,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const EstadoVacio(
            titulo: 'Algo salió mal',
            mensaje: 'No se pudieron cargar los proveedores.',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Proveedor> proveedores = snapshot.data!;

        // Requisito: estado vacío
        if (proveedores.isEmpty) {
          return const EstadoVacio(
            titulo: 'Todavía no hay proveedores',
            mensaje:
                'Registra a quien te surte para poder asignarle productos.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: proveedores.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _construirTarjeta(proveedores[index]);
          },
        );
      },
    );
  }

  // Requisito: tarjeta con los datos de contacto del proveedor
  Widget _construirTarjeta(Proveedor proveedor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirIniciales(proveedor.nombre),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proveedor.nombre,
                    style: const TextStyle(
                      fontFamily: 'ZillaSlab',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colores.tinta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _construirDato(
                    'Tel.',
                    proveedor.telefono,
                    'Sin teléfono',
                    'PlexMono',
                  ),
                  const SizedBox(height: 4),
                  _construirDato(
                    'Correo',
                    proveedor.correo,
                    'Sin correo',
                    'PlexSans',
                  ),
                ],
              ),
            ),
            // Requisito: opciones de editar y eliminar
            MenuOpciones(
              alEditar: () {
                _abrirFormulario(proveedor);
              },
              alEliminar: () {
                _eliminarProveedor(proveedor);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Cuadro con las iniciales: "Distribuidora Andina" -> "DA"
  Widget _construirIniciales(String nombre) {
    // Separamos el nombre en palabras (sin espacios vacíos)
    List<String> palabras = nombre.trim().split(' ');
    palabras.removeWhere((palabra) => palabra.isEmpty);

    // Primera letra de la primera palabra y, si hay más, de la última
    String iniciales = palabras.first[0];
    if (palabras.length > 1) {
      iniciales = iniciales + palabras.last[0];
    }

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colores.verdeSuave,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        iniciales.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'ZillaSlab',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colores.verde,
        ),
      ),
    );
  }

  // Una fila "etiqueta  valor"; si el dato está vacío muestra un texto gris
  Widget _construirDato(
    String etiqueta,
    String? dato,
    String textoVacio,
    String letra,
  ) {
    bool vacio = dato == null || dato.isEmpty;

    // Estilo del valor: tinta normal, o gris en cursiva si falta el dato
    TextStyle estiloValor = TextStyle(
      fontFamily: letra,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colores.tinta,
    );
    if (vacio) {
      estiloValor = const TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Colores.gris,
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            etiqueta,
            style: const TextStyle(fontSize: 13, color: Colores.gris),
          ),
        ),
        Expanded(
          child: Text(
            vacio ? textoVacio : dato,
            overflow: TextOverflow.ellipsis,
            style: estiloValor,
          ),
        ),
      ],
    );
  }
}
