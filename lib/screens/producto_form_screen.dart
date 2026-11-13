// Formulario para crear un producto nuevo o editar uno existente.
import 'package:flutter/material.dart';
import 'package:inventario_app/models/producto.dart';
import 'package:inventario_app/models/proveedor.dart';
import 'package:inventario_app/routes/app_routes.dart';
import 'package:inventario_app/services/producto_service.dart';
import 'package:inventario_app/services/proveedor_service.dart';
import 'package:inventario_app/widgets/campo_texto.dart';
import 'package:inventario_app/widgets/estado_vacio.dart';

class ProductoFormScreen extends StatefulWidget {
  // Si producto es null se crea uno nuevo; si no, se edita
  final Producto? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  // Llave para validar todo el formulario de una vez
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _precio = TextEditingController();
  final _stock = TextEditingController();
  int? _proveedorSeleccionado;

  final ProductoService _productoService = ProductoService();
  final ProveedorService _proveedorService = ProveedorService();
  late Future<List<Proveedor>> _futuroProveedores;

  @override
  void initState() {
    super.initState();
    // Requisito: el Dropdown muestra los proveedores existentes
    _futuroProveedores = _proveedorService.obtenerProveedores();

    // Si estamos editando, llenamos los campos con los datos actuales
    if (widget.producto != null) {
      _nombre.text = widget.producto!.nombre;
      _stock.text = widget.producto!.stock.toString();
      _proveedorSeleccionado = widget.producto!.proveedorId;

      // Si el precio no tiene decimales lo mostramos sin ".0"
      double precio = widget.producto!.precio;
      if (precio == precio.truncateToDouble()) {
        _precio.text = precio.toInt().toString();
      } else {
        _precio.text = precio.toString();
      }
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _stock.dispose();
    super.dispose();
  }

  // Requisito: validar campos obligatorios
  String? _validarNombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    return null;
  }

  // Requisito: validar valores numéricos (precio)
  String? _validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El precio es obligatorio';
    }
    double? precio = double.tryParse(valor.trim());
    if (precio == null) {
      return 'Escribe un número válido';
    }
    if (precio <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    return null;
  }

  // Requisito: validar valores numéricos (stock entero)
  String? _validarStock(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El stock es obligatorio';
    }
    int? stock = int.tryParse(valor.trim());
    if (stock == null) {
      return 'Escribe un número entero';
    }
    if (stock < 0) {
      return 'El stock no puede ser negativo';
    }
    return null;
  }

  // Requisito: guardar (crear o actualizar) solo si el formulario es válido
  Future<void> _guardar() async {
    // Oculta el teclado para que se vean bien los mensajes de error
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Producto producto = Producto(
      id: widget.producto?.id,
      nombre: _nombre.text.trim(),
      precio: double.parse(_precio.text.trim()),
      stock: int.parse(_stock.text.trim()),
      proveedorId: _proveedorSeleccionado!,
    );

    if (widget.producto == null) {
      await _productoService.insertarProducto(producto);
    } else {
      await _productoService.actualizarProducto(producto);
    }

    if (!mounted) {
      return;
    }
    // Devolvemos true para que la lista sepa que debe recargarse
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.producto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: FutureBuilder<List<Proveedor>>(
        future: _futuroProveedores,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Proveedor> proveedores = snapshot.data!;

          // Requisito: sin proveedores no se puede crear un producto
          if (proveedores.isEmpty) {
            return EstadoVacio(
              titulo: 'Primero registra un proveedor',
              mensaje: 'Cada producto debe tener a alguien que lo surta.',
              textoBoton: 'Ir a proveedores',
              alPresionar: () {
                Navigator.pushReplacementNamed(context, AppRoutes.proveedores);
              },
            );
          }

          return _construirFormulario(proveedores, esEdicion);
        },
      ),
    );
  }

  Widget _construirFormulario(List<Proveedor> proveedores, bool esEdicion) {
    // Opciones del Dropdown: el valor es el id y se muestra el nombre
    List<DropdownMenuItem<int>> opciones = [];
    for (var proveedor in proveedores) {
      opciones.add(
        DropdownMenuItem(value: proveedor.id, child: Text(proveedor.nombre)),
      );
    }

    // Ancho máximo de 700 para que se vea ordenado en tablets
    return Align(
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
                  etiqueta: 'Nombre',
                  controller: _nombre,
                  validator: _validarNombre,
                ),
                CampoTexto(
                  etiqueta: 'Precio',
                  controller: _precio,
                  validator: _validarPrecio,
                  tipoTeclado: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                CampoTexto(
                  etiqueta: 'Stock',
                  controller: _stock,
                  validator: _validarStock,
                  tipoTeclado: TextInputType.number,
                ),
                // Requisito: seleccionar un proveedor existente con Dropdown
                const EtiquetaCampo(texto: 'Proveedor'),
                DropdownButtonFormField<int>(
                  initialValue: _proveedorSeleccionado,
                  items: opciones,
                  hint: const Text('Elige quién lo surte'),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  onChanged: (valor) {
                    setState(() {
                      _proveedorSeleccionado = valor;
                    });
                  },
                  validator: (valor) {
                    if (valor == null) {
                      return 'Selecciona un proveedor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar producto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
