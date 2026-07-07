import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => InventarioPageState();
}

class InventarioPageState extends State<InventarioPage> {
  List<Map<String, dynamic>> inventario = [];
  List<Map<String, dynamic>> catalogo = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final inventarioJson =
        await rootBundle.loadString('assets/data/inventario.json');
    final catalogoJson =
        await rootBundle.loadString('assets/data/materiales.json');

    final List<dynamic> datosInventario = jsonDecode(inventarioJson);
    final List<dynamic> datosCatalogo = jsonDecode(catalogoJson);

    setState(() {
      inventario = datosInventario.cast<Map<String, dynamic>>();
      catalogo = datosCatalogo.cast<Map<String, dynamic>>();
      cargando = false;
    });
  }

  Map<String, dynamic>? _buscarEnCatalogo(String codigo) {
    try {
      return catalogo.firstWhere((m) => m['codigo'] == codigo);
    } catch (_) {
      return null;
    }
  }

  bool registrarEntrada(String codigo, int cantidad, String obra) {
    final index = inventario.indexWhere((m) => m['codigo'] == codigo);
    if (index == -1) {
      _mostrarSnackBar('Material con código $codigo no encontrado',
          esError: true);
      return false;
    }

    setState(() {
      inventario[index]['stock'] =
          (inventario[index]['stock'] as int) + cantidad;
      inventario[index]['obra'] = obra;
    });

    final infoCatalogo = _buscarEnCatalogo(codigo);
    final nombre = infoCatalogo?['nombre'] ?? codigo;
    _mostrarSnackBar('Entrada registrada: +$cantidad de $nombre en $obra');
    return true;
  }
  bool registrarSalida(String codigo, int cantidad) {
    final index = inventario.indexWhere((m) => m['codigo'] == codigo);
    if (index == -1) {
      _mostrarSnackBar('Material con código $codigo no encontrado',
          esError: true);
      return false;
    }

    final stockActual = inventario[index]['stock'] as int;
    if (cantidad > stockActual) {
      _mostrarSnackBar(
          'Salida rechazada: stock insuficiente ($stockActual)',
          esError: true);
      return false;
    }

    setState(() {
      inventario[index]['stock'] = stockActual - cantidad;
    });

    final infoCatalogo = _buscarEnCatalogo(codigo);
    final nombre = infoCatalogo?['nombre'] ?? codigo;
    _mostrarSnackBar('Salida registrada: -$cantidad de $nombre');
    return true;
  }

  void _mostrarSnackBar(String mensaje, {bool esError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red[700] : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3)
      )
    );
  }

  bool _esCritico(int stock, int stockMinimo) {
    return stock <= stockMinimo;
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFFCFD8DC),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: inventario.length,
        itemBuilder: (context, index) {
          final item = inventario[index];
          final infoCatalogo = _buscarEnCatalogo(item['codigo']);
          return _InventarioCard(
            item: item,
            infoCatalogo: infoCatalogo,
            esCritico: infoCatalogo != null
                ? _esCritico(
                    item['stock'] as int,
                    infoCatalogo['stockMinimo'] as int,
                  )
                : false,
          );
        }
      )
    );
  }
}

class _InventarioCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, dynamic>? infoCatalogo;
  final bool esCritico;

  const _InventarioCard({
    required this.item,
    required this.infoCatalogo,
    required this.esCritico,
  });

  @override
  Widget build(BuildContext context) {
    final stock = item['stock'] as int;
    final obra = item['obra'] as String;
    final codigo = item['codigo'] as String;

    final nombre = infoCatalogo?['nombre'] ?? codigo;
    final unidad = infoCatalogo?['unidad'] ?? '';
    final stockMinimo = infoCatalogo?['stockMinimo'] as int? ?? 0;
    final categoria = infoCatalogo?['categoria'] ?? '';

    final Color colorBorde =
        esCritico ? const Color(0xFFC62828) : Colors.transparent;
    final Color colorStock =
        esCritico ? const Color(0xFFC62828) : Colors.black87;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: esCritico
            ? BorderSide(color: colorBorde, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF37474F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Código: $codigo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF546E7A),
                        ),
                      ),
                    ],
                  ),
                ),
                if (esCritico)
                  _AlertaBadge(color: colorBorde),
              ],
            ),

            const Divider(height: 16),
            Row(
              children: [
                Icon(Icons.inventory_2, size: 16, color: colorStock),
                const SizedBox(width: 6),
                Text(
                  'Disponible: ',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  '$stock $unidad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorStock,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '(Mín: $stockMinimo)',
                  style: TextStyle(
                    fontSize: 12,
                    color: esCritico
                        ? const Color(0xFFC62828)
                        : const Color(0xFF78909C),
                    fontWeight:
                        esCritico ? FontWeight.bold : FontWeight.normal,
                  )
                )
              ]
            ),

            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.construction, size: 16, color: Color(0xFF78909C)),
                const SizedBox(width: 6),
                Text(
                  'Obra: ',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Expanded(
                  child: Text(
                    obra,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ]
            ),

            if (categoria.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Color(0xFF78909C)),
                  const SizedBox(width: 6),
                  Text(
                    'Categoría: ',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Expanded(
                    child: Text(
                      categoria,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  )
                ]
              )
            ],

            if (esCritico) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFC62828).withValues(alpha: 0.3),
                  )
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Color(0xFFC62828)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Stock por debajo del mínimo establecido en catálogo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC62828),
                        )
                      )
                    )
                  ]
                )
              )
            ]
          ]
        )
      )
    );
  }
}

class _AlertaBadge extends StatefulWidget {
  final Color color;

  const _AlertaBadge({required this.color});

  @override
  State<_AlertaBadge> createState() => _AlertaBadgeState();
}

class _AlertaBadgeState extends State<_AlertaBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.color, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 14, color: widget.color),
                const SizedBox(width: 4),
                Text(
                  '¡CRÍTICO!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  )
                )
              ]
            )
          )
        );
      }
    );
  }
}
