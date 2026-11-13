// Pantalla con el listado de productos: búsqueda, editar y eliminar.
import 'package:flutter/material.dart';
import 'package:inventario_app/models/producto.dart';
import 'package:inventario_app/screens/producto_form_screen.dart';
import 'package:inventario_app/services/producto_service.dart';
import 'package:inventario_app/utils/colores.dart';
import 'package:inventario_app/widgets/estado_vacio.dart';
import 'package:inventario_app/widgets/etiqueta_precio.dart';
import 'package:inventario_app/widgets/menu_opciones.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _productoService = ProductoService();

  // Consulta actual de productos y texto que se está buscando
  late Future<List<Producto>> _futuroProductos;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _futuroProductos = _productoService.obtenerProductos();
  }

  // Vuelve a consultar la base de datos y redibuja la lista
  void _cargarProductos() {
    setState(() {
      _futuroProductos = _productoService.obtenerProductos(busqueda: _busqueda);
    });
  }

  // Abre el formulario (vacío para crear, con datos para editar)
  Future<void> _abrirFormulario(Producto? producto) async {
    final guardado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(producto: producto),
      ),
    );
    // Requisito: mensaje de confirmación al guardar
    if (guardado == true) {
      _mostrarMensaje('Producto guardado');
      _cargarProductos();
    }
  }

  // Requisito: eliminar productos con confirmación previa
  Future<void> _eliminarProducto(Producto producto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar «${producto.nombre}»?'),
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
    await _productoService.eliminarProducto(producto.id!);
    _mostrarMensaje('Producto eliminado');
    _cargarProductos();
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
      appBar: AppBar(title: const Text('Productos')),
      // Botón fijo abajo, fácil de alcanzar con el pulgar
      bottomNavigationBar: _construirBotonAgregar(),
      // Ancho máximo de 700 para que se vea ordenado en tablets
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              _construirBuscador(),
              Expanded(child: _construirLista()),
            ],
          ),
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
              child: const Text('Agregar producto'),
            ),
          ),
        ),
      ),
    );
  }

  // Requisito: búsqueda o filtro por nombre
  Widget _construirBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar por nombre',
          prefixIcon: Icon(Icons.search_outlined, color: Colores.gris),
        ),
        // Cada vez que se escribe, se vuelve a consultar con el nuevo texto
        onChanged: (texto) {
          _busqueda = texto;
          _cargarProductos();
        },
      ),
    );
  }

  // Requisito: listado con FutureBuilder
  Widget _construirLista() {
    return FutureBuilder<List<Producto>>(
      future: _futuroProductos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const EstadoVacio(
            titulo: 'Algo salió mal',
            mensaje: 'No se pudieron cargar los productos.',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Producto> productos = snapshot.data!;

        // Requisito: estados vacíos
        if (productos.isEmpty && _busqueda.isNotEmpty) {
          return EstadoVacio(
            titulo: 'Sin resultados',
            mensaje: 'No hay productos que contengan «$_busqueda».',
          );
        }
        if (productos.isEmpty) {
          return const EstadoVacio(
            titulo: 'Todavía no hay productos',
            mensaje: 'Agrega el primero y aparecerá aquí con su precio y existencias.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: productos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _construirTarjeta(productos[index]);
          },
        );
      },
    );
  }

  // Requisito: tarjeta con nombre, precio, stock y nombre del proveedor
  Widget _construirTarjeta(Producto producto) {
    // Franja roja a la izquierda solo si queda poco stock
    Color colorFranja = Colors.transparent;
    if (producto.stockBajo) {
      colorFranja = Colores.rojo;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      // IntrinsicHeight hace que la franja mida lo mismo que la tarjeta
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: colorFranja),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 0, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colores.tinta,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      producto.nombreProveedor ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colores.gris),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        EtiquetaPrecio(precio: producto.precio),
                        const SizedBox(width: 12),
                        _construirTextoStock(producto),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Requisito: opciones de editar y eliminar
            Align(
              alignment: Alignment.topCenter,
              child: MenuOpciones(
                alEditar: () {
                  _abrirFormulario(producto);
                },
                alEliminar: () {
                  _eliminarProducto(producto);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // "40 en estante" en gris, o "Quedan 3" en rojo si queda poco
  Widget _construirTextoStock(Producto producto) {
    String texto = '${producto.stock} en estante';
    Color color = Colores.gris;
    if (producto.stockBajo) {
      texto = 'Quedan ${producto.stock}';
      color = Colores.rojo;
    }

    return Text(
      texto,
      style: TextStyle(
        fontFamily: 'PlexMono',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }
}
