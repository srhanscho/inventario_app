// Funciones de ayuda para mostrar datos con buen formato.

// Convierte 12500 en "$ 12.500" (puntos de miles y sin decimales)
String formatearPrecio(double precio) {
  // Redondeamos y pasamos a texto: 12500.0 -> "12500"
  String numero = precio.round().toString();
  String resultado = '';
  int contador = 0;

  // Recorremos los dígitos de derecha a izquierda;
  // cada 3 dígitos agregamos un punto
  for (int i = numero.length - 1; i >= 0; i--) {
    resultado = numero[i] + resultado;
    contador++;
    if (contador % 3 == 0 && i > 0) {
      resultado = '.$resultado';
    }
  }

  return '\$ $resultado';
}

// Devuelve la fecha en español, por ejemplo "Martes, 10 de noviembre"
String fechaDeHoy([DateTime? fecha]) {
  // Si no llega una fecha, usamos la de hoy
  DateTime dia = fecha ?? DateTime.now();

  // weekday va de 1 (lunes) a 7 (domingo); month va de 1 a 12
  List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  List<String> meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  // Restamos 1 porque las listas empiezan en la posición 0
  String nombreDia = dias[dia.weekday - 1];
  String nombreMes = meses[dia.month - 1];
  return '$nombreDia, ${dia.day} de $nombreMes';
}
