import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prestamo.dart';
import '../models/resumen.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/prestamo_service.dart';
import '../services/token_storage.dart';
import '../widgets/prestamo_card.dart';
import '../widgets/resumen_card.dart';
import 'prestamo_form_screen.dart';

class PrestamosScreen extends StatefulWidget {
  final PrestamoService prestamoService;
  final AuthService authService;
  final TokenStorage tokenStorage;

  const PrestamosScreen({
    super.key,
    required this.prestamoService,
    required this.authService,
    required this.tokenStorage,
  });

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  final _searchCtrl = TextEditingController();
  List<Prestamo> _todos = [];
  Resumen? _resumen;
  String? _nombreUsuario;
  bool _loading = true;
  String? _errorMsg;
  String _query = '';
  Timer? _expiryTimer;
  bool _expiryWarned = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
    _checkTokenExpiry();
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkTokenExpiry(),
    );
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkTokenExpiry() async {
    final token = await widget.tokenStorage.getToken();
    if (token == null || !mounted) return;
    final exp = TokenStorage.decodeExpiration(token);
    if (exp == null) return;
    final remaining = exp.difference(DateTime.now());
    if (remaining.inSeconds > 0 && remaining.inMinutes <= 5 && !_expiryWarned) {
      _expiryWarned = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aviso: tu sesión expira en ${remaining.inMinutes + 1} min',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _loadUserAndData() async {
    final nombre = await widget.tokenStorage.getNombre();
    if (mounted) {
      setState(() => _nombreUsuario = nombre);
    }
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final results = await Future.wait([
        widget.prestamoService.listar(),
        widget.prestamoService.resumen(),
      ]);
      if (!mounted) return;
      setState(() {
        _todos = results[0] as List<Prestamo>;
        _resumen = results[1] as Resumen;
      });
    } on UnauthorizedException {
      return;
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openForm([Prestamo? prestamo]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PrestamoFormScreen(
          prestamoService: widget.prestamoService,
          prestamo: prestamo,
        ),
      ),
    );
    if (saved == true) {
      await _loadData();
    }
  }

  Future<void> _markPaid(Prestamo p) async {
    try {
      await widget.prestamoService.marcarPagado(p);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préstamo marcado como cobrado')),
        );
      }
    } on UnauthorizedException {
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _confirmDelete(Prestamo p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Anular préstamo'),
        content: Text(
          '¿Seguro que deseas anular el préstamo de ${p.cliente}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Anular'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.prestamoService.eliminar(p.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préstamo anulado')),
        );
      }
    } on UnauthorizedException {
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  List<Prestamo> _filterList(bool pagados) {
    final q = _query.trim().toLowerCase();
    return _todos.where((p) {
      if (p.pagado != pagados) return false;
      if (q.isEmpty) return true;
      return p.cliente.toLowerCase().contains(q) || p.dni.startsWith(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final porCobrar = _filterList(false);
    final cobrados = _filterList(true);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PrestaControl'),
              if (_nombreUsuario != null && _nombreUsuario!.isNotEmpty)
                Text(
                  _nombreUsuario!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Por cobrar'),
              Tab(text: 'Cobrados'),
            ],
          ),
        ),
        body: Column(
          children: [
            ResumenCard(resumen: _resumen),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por cliente o DNI...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _errorMsg!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _PrestamosList(
                          items: porCobrar,
                          emptyMessage: 'No hay préstamos por cobrar',
                          onRefresh: _loadData,
                          onEdit: _openForm,
                          onMarkPaid: _markPaid,
                          onDelete: _confirmDelete,
                        ),
                        _PrestamosList(
                          items: cobrados,
                          emptyMessage: 'No hay préstamos cobrados',
                          onRefresh: _loadData,
                          onEdit: _openForm,
                          onMarkPaid: _markPaid,
                          onDelete: _confirmDelete,
                        ),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openForm(),
          tooltip: 'Nuevo préstamo',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _PrestamosList extends StatelessWidget {
  final List<Prestamo> items;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final void Function(Prestamo) onEdit;
  final void Function(Prestamo) onMarkPaid;
  final void Function(Prestamo) onDelete;

  const _PrestamosList({
    required this.items,
    required this.emptyMessage,
    required this.onRefresh,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                Center(child: Text(emptyMessage)),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 84),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final p = items[index];
                return PrestamoCard(
                  prestamo: p,
                  onEdit: () => onEdit(p),
                  onMarkPaid: () => onMarkPaid(p),
                  onDelete: () => onDelete(p),
                );
              },
            ),
    );
  }
}
