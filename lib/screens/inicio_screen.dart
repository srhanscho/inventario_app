// Pantalla principal (dashboard): fecha, totales, lo que hay que reponer y accesos.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario_app/models/producto.dart';
import 'package:inventario_app/routes/app_routes.dart';
import 'package:inventario_app/services/producto_service.dart';
import 'package:inventario_app/services/proveedor_service.dart';
import 'package:inventario_app/utils/colores.dart';
import 'package:inventario_app/utils/formato.dart';
import 'package:inventario_app/widgets/tarjeta_acceso.dart';
import 'package:inventario_app/widgets/tarjeta_resumen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final ProductoService _productoService = ProductoService();
  final ProveedorService _proveedorService = ProveedorService();

  // Consultas que usan los FutureBuilder de esta pantalla
  late Future<List<int>> _futuroTotales;
  late Future<List<Producto>> _futuroProductos;

  @override
  void initState() {
    super.initState();
    _futuroTotales = _obtenerTotales();
    _futuroProductos = _productoService.obtenerProductos();
  }

  // Requisito: totales de productos y proveedores (consultas asíncronas)
  Future<List<int>> _obtenerTotales() async {
    int totalProductos = await _productoService.contarProductos();
    int totalProveedores = await _proveedorService.contarProveedores();
    return [totalProductos, totalProveedores];
  }

  // Vuelve a consultar los datos y redibuja la pantalla
  void _cargarDatos() {
    setState(() {
      _futuroTotales = _obtenerTotales();
      _futuroProductos = _productoService.obtenerProductos();
    });
  }

  // Abre una sección y, al regresar, actualiza los datos
  Future<void> _abrirSeccion(String ruta) async {
    await Navigator.pushNamed(context, ruta);
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    // Iconos oscuros en la barra de estado, porque el fondo es claro
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            // Ancho máximo de 700 para que se vea ordenado en tablets
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirEncabezado(),
                      const SizedBox(height: 24),
                      _construirResumen(),
                      const SizedBox(height: 32),
                      _construirTitulo('Por reponer'),
                      _construirPorReponer(),
                      const SizedBox(height: 32),
                      _construirTitulo('Secciones'),
                      _construirAccesos(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Requisito: nombre e identidad visual de la app
  Widget _construirEncabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fechaDeHoy(),
          style: const TextStyle(fontSize: 14, color: Colores.gris),
        ),
        const SizedBox(height: 4),
        const Text(
          'Inventario',
          style: TextStyle(
            fontFamily: 'ZillaSlab',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: Colores.tinta,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lo que tienes en la tienda y quién te lo surte.',
          style: TextStyle(fontSize: 15, color: Colores.gris),
        ),
      ],
    );
  }

  Widget _construirTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: 'ZillaSlab',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colores.tinta,
        ),
      ),
    );
  }

  // Requisito: tarjetas de resumen con FutureBuilder
  Widget _construirResumen() {
    return FutureBuilder<List<int>>(
      future: _futuroTotales,
      builder: (context, snapshot) {
        // Mientras llegan los datos mostramos "-"
        String productos = '-';
        String proveedores = '-';
        if (snapshot.hasData) {
          productos = snapshot.data![0].toString();
          proveedores = snapshot.data![1].toString();
        }

        // Expanded reparte el ancho en partes iguales (se adapta a la pantalla)
        return Row(
          children: [
            Expanded(
              child: TarjetaResumen(
                valor: productos,
                etiqueta: 'productos',
                colorFondo: Colores.verde,
                colorTexto: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TarjetaResumen(
                valor: proveedores,
                etiqueta: 'proveedores',
                colorFondo: Colores.amarillo,
                colorTexto: Colores.tinta,
              ),
            ),
          ],
        );
      },
    );
  }

  // Lista corta de productos con stock bajo
  Widget _construirPorReponer() {
    return FutureBuilder<List<Producto>>(
      future: _futuroProductos,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 24);
        }

        List<Producto> productos = snapshot.data!;
        if (productos.isEmpty) {
          return _construirNota('Aún no hay productos registrados.');
        }

        // Nos quedamos solo con los productos que tienen stock bajo
        List<Producto> porReponer = [];
        for (var producto in productos) {
          if (producto.stockBajo) {
            porReponer.add(producto);
          }
        }
        if (porReponer.isEmpty) {
          return _construirNota('Todo el stock está en orden.');
        }

        // Una fila por producto, separadas por una línea fina
        List<Widget> filas = [];
        for (int i = 0; i < porReponer.length; i++) {
          if (i > 0) {
            filas.add(const Divider(height: 1));
          }
          filas.add(_construirFilaReponer(porReponer[i]));
        }
        return Card(child: Column(children: filas));
      },
    );
  }

  Widget _construirFilaReponer(Producto producto) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
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
                  style: const TextStyle(fontSize: 13, color: Colores.gris),
                ),
              ],
            ),
          ),
          Text(
            'Quedan ${producto.stock}',
            style: const TextStyle(
              fontFamily: 'PlexMono',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colores.rojo,
            ),
          ),
        ],
      ),
    );
  }

  // Una línea de texto gris, para cuando no hay nada que mostrar
  Widget _construirNota(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 15, color: Colores.gris),
    );
  }

  // Requisito: accesos visibles a productos y proveedores
  Widget _construirAccesos() {
    return Card(
      // Recorta el efecto al tocar para que respete las esquinas
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          TarjetaAcceso(
            titulo: 'Productos',
            descripcion: 'Precios, existencias y búsqueda',
            onTap: () {
              _abrirSeccion(AppRoutes.productos);
            },
          ),
          const Divider(height: 1),
          TarjetaAcceso(
            titulo: 'Proveedores',
            descripcion: 'Quién te surte y cómo contactarlo',
            onTap: () {
              _abrirSeccion(AppRoutes.proveedores);
            },
          ),
        ],
      ),
    );
  }
}
