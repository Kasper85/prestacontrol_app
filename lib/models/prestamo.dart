class Prestamo {
  final int id;
  final String cliente;
  final String dni;
  final double monto;
  final double interes;
  final double totalACobrar;
  final DateTime fechaPrestamo;
  final DateTime fechaVencimiento;
  final bool pagado;

  const Prestamo({
    required this.id,
    required this.cliente,
    required this.dni,
    required this.monto,
    required this.interes,
    required this.totalACobrar,
    required this.fechaPrestamo,
    required this.fechaVencimiento,
    required this.pagado,
  });

  bool get estaVencido {
    if (pagado) return false;
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final venc = DateTime(
      fechaVencimiento.year,
      fechaVencimiento.month,
      fechaVencimiento.day,
    );
    return venc.isBefore(hoy);
  }

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: (json['id'] as num).toInt(),
      cliente: json['cliente'] as String,
      dni: json['dni'] as String,
      monto: (json['monto'] as num).toDouble(),
      interes: (json['interes'] as num).toDouble(),
      totalACobrar: (json['totalACobrar'] as num).toDouble(),
      fechaPrestamo: DateTime.parse(json['fechaPrestamo'] as String),
      fechaVencimiento: DateTime.parse(json['fechaVencimiento'] as String),
      pagado: json['pagado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final yyyy = fechaVencimiento.year.toString().padLeft(4, '0');
    final mm = fechaVencimiento.month.toString().padLeft(2, '0');
    final dd = fechaVencimiento.day.toString().padLeft(2, '0');
    return {
      'cliente': cliente,
      'dni': dni,
      'monto': monto,
      'interes': interes,
      'fechaVencimiento': '$yyyy-$mm-$dd',
      'pagado': pagado,
    };
  }

  Prestamo copyWith({
    int? id,
    String? cliente,
    String? dni,
    double? monto,
    double? interes,
    double? totalACobrar,
    DateTime? fechaPrestamo,
    DateTime? fechaVencimiento,
    bool? pagado,
  }) {
    return Prestamo(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      dni: dni ?? this.dni,
      monto: monto ?? this.monto,
      interes: interes ?? this.interes,
      totalACobrar: totalACobrar ?? this.totalACobrar,
      fechaPrestamo: fechaPrestamo ?? this.fechaPrestamo,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      pagado: pagado ?? this.pagado,
    );
  }
}
