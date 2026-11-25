import 'package:flutter_test/flutter_test.dart';
import 'package:prestacontrol_app/models/auth_response.dart';
import 'package:prestacontrol_app/models/prestamo.dart';
import 'package:prestacontrol_app/models/resumen.dart';

void main() {
  test('Prestamo.fromJson y toJson funcionan correctamente', () {
    final json = {
      'id': 1,
      'cliente': 'Carlos Perez',
      'dni': '12345678',
      'monto': 1000.0,
      'interes': 15.0,
      'totalACobrar': 1150.0,
      'fechaPrestamo': '2026-11-25',
      'fechaVencimiento': '2026-12-10',
      'pagado': false,
    };

    final p = Prestamo.fromJson(json);
    expect(p.id, 1);
    expect(p.cliente, 'Carlos Perez');
    expect(p.totalACobrar, 1150.0);
    expect(p.pagado, false);

    final out = p.toJson();
    expect(out['dni'], '12345678');
    expect(out['fechaVencimiento'], '2026-12-10');
    expect(out['pagado'], false);
  });

  test('Resumen.fromJson y AuthResponse.fromJson parsean campos', () {
    final resumen = Resumen.fromJson({
      'capitalPrestado': 2000,
      'totalPorCobrar': 2300,
      'gananciaEsperada': 300,
      'cantidadPrestamos': 2,
      'cantidadVencidos': 1,
    });
    expect(resumen.totalPorCobrar, 2300.0);
    expect(resumen.cantidadVencidos, 1);

    final auth = AuthResponse.fromJson({
      'token': 'abc.def.ghi',
      'nombre': 'Julio',
      'email': 'julio@test.com',
    });
    expect(auth.token, 'abc.def.ghi');
    expect(auth.nombre, 'Julio');
  });
}
