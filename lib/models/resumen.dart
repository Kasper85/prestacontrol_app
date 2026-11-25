class Resumen {
  final double capitalPrestado;
  final double totalPorCobrar;
  final double gananciaEsperada;
  final int cantidadPrestamos;
  final int cantidadVencidos;

  const Resumen({
    required this.capitalPrestado,
    required this.totalPorCobrar,
    required this.gananciaEsperada,
    required this.cantidadPrestamos,
    required this.cantidadVencidos,
  });

  factory Resumen.fromJson(Map<String, dynamic> json) {
    return Resumen(
      capitalPrestado: (json['capitalPrestado'] as num).toDouble(),
      totalPorCobrar: (json['totalPorCobrar'] as num).toDouble(),
      gananciaEsperada: (json['gananciaEsperada'] as num).toDouble(),
      cantidadPrestamos: (json['cantidadPrestamos'] as num).toInt(),
      cantidadVencidos: (json['cantidadVencidos'] as num).toInt(),
    );
  }
}
