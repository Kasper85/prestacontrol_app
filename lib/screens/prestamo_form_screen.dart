import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prestamo.dart';
import '../services/api_client.dart';
import '../services/prestamo_service.dart';

class PrestamoFormScreen extends StatefulWidget {
  final PrestamoService prestamoService;
  final Prestamo? prestamo;

  const PrestamoFormScreen({
    super.key,
    required this.prestamoService,
    this.prestamo,
  });

  @override
  State<PrestamoFormScreen> createState() => _PrestamoFormScreenState();
}

class _PrestamoFormScreenState extends State<PrestamoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clienteCtrl;
  late final TextEditingController _dniCtrl;
  late final TextEditingController _montoCtrl;
  late final TextEditingController _interesCtrl;
  late DateTime _fechaVencimiento;
  bool _saving = false;
  String? _errorMsg;

  bool get _isEditing => widget.prestamo != null;

  @override
  void initState() {
    super.initState();
    final p = widget.prestamo;
    _clienteCtrl = TextEditingController(text: p?.cliente ?? '');
    _dniCtrl = TextEditingController(text: p?.dni ?? '');
    _montoCtrl = TextEditingController(
      text: p != null ? p.monto.toStringAsFixed(2) : '',
    );
    _interesCtrl = TextEditingController(
      text: p != null ? p.interes.toStringAsFixed(2) : '',
    );
    _fechaVencimiento = p?.fechaVencimiento ??
        DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _dniCtrl.dispose();
    _montoCtrl.dispose();
    _interesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = _isEditing
        ? DateTime(2020)
        : DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento.isBefore(firstDate)
          ? firstDate
          : _fechaVencimiento,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _fechaVencimiento = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _errorMsg = null;
    });

    final monto = double.parse(_montoCtrl.text.trim().replaceAll(',', '.'));
    final interes = double.parse(_interesCtrl.text.trim().replaceAll(',', '.'));
    final total = monto + (monto * interes / 100);

    final payload = Prestamo(
      id: widget.prestamo?.id ?? 0,
      cliente: _clienteCtrl.text.trim(),
      dni: _dniCtrl.text.trim(),
      monto: monto,
      interes: interes,
      totalACobrar: total,
      fechaPrestamo: widget.prestamo?.fechaPrestamo ?? DateTime.now(),
      fechaVencimiento: _fechaVencimiento,
      pagado: widget.prestamo?.pagado ?? false,
    );

    try {
      if (_isEditing) {
        await widget.prestamoService.actualizar(payload);
      } else {
        await widget.prestamoService.crear(payload);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on UnauthorizedException {
      return;
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar préstamo' : 'Nuevo préstamo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _clienteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del cliente',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el cliente' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dniCtrl,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'DNI (8 dígitos)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || !RegExp(r'^\d{8}$').hasMatch(v.trim())) {
                    return 'El DNI debe tener exactamente 8 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto prestado (S/)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return 'Ingresa un monto mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _interesCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Interés (%)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (parsed == null || parsed < 0 || parsed > 999.99) {
                    return 'Ingresa un interés válido (0 - 999.99)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de vencimiento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dateFmt.format(_fechaVencimiento)),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Guardar cambios' : 'Registrar préstamo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
