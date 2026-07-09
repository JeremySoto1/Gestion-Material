import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Módulo: USO DE MATERIAL
///
/// Permite seleccionar un material del inventario, indicar la actividad,
/// cantidad, fecha de uso y prioridad, y registrar la salida de stock
/// llamando al callback [onRegistrarSalida] (implementado en Inventario).
class UsoMaterialPage extends StatefulWidget {
  /// Debe devolver true si la salida se registró correctamente
  /// (ej: PrincipalPage.registrarSalidaMaterial).
  final bool Function(String codigo, int cantidad) onRegistrarSalida;

  const UsoMaterialPage({super.key, required this.onRegistrarSalida});

  @override
  State<UsoMaterialPage> createState() => _UsoMaterialPageState();
}

class _UsoMaterialPageState extends State<UsoMaterialPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<Map<String, dynamic>> catalogo = [];
  List<Map<String, dynamic>> inventario = [];
  bool cargando = true;

  final List<Map<String, dynamic>> historialUsos = [];

  // Lista fija de actividades (spinner / combobox)
  static const List<String> actividades = [
    'Encofrado y hormigonado',
    'Instalaciones eléctricas',
    'Instalaciones sanitarias',
    'Acabados y pintura',
    'Mampostería',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final catalogoJson =
    await rootBundle.loadString('assets/data/materiales.json');
    final inventarioJson =
    await rootBundle.loadString('assets/data/inventario.json');

    final List<dynamic> datosCatalogo = jsonDecode(catalogoJson);
    final List<dynamic> datosInventario = jsonDecode(inventarioJson);

    setState(() {
      catalogo = datosCatalogo.cast<Map<String, dynamic>>();
      // Copia local para reflejar el stock disponible en esta pantalla.
      inventario = datosInventario
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      cargando = false;
    });
  }

  Map<String, dynamic>? _catalogoDe(String codigo) {
    try {
      return catalogo.firstWhere((m) => m['codigo'] == codigo);
    } catch (_) {
      return null;
    }
  }

  void _mostrarSnackBar(String mensaje, {bool esError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red[700] : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _abrirDialogoUso(Map<String, dynamic> itemInventario) async {
    final codigo = itemInventario['codigo'] as String;
    final infoCatalogo = _catalogoDe(codigo);
    final nombre = infoCatalogo?['nombre'] ?? codigo;
    final unidad = infoCatalogo?['unidad'] ?? '';
    final stockDisponible = itemInventario['stock'] as int;

    final cantidadController = TextEditingController();
    final fechaController = TextEditingController(
      text:
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );

    String actividadSeleccionada = actividades.first;
    String prioridad = 'Normal';
    bool requiereReposicion = false;
    DateTime fechaUso = DateTime.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> seleccionarFecha() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: fechaUso,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setDialogState(() {
                  fechaUso = picked;
                  fechaController.text =
                  '${picked.day}/${picked.month}/${picked.year}';
                });
              }
            }

            return AlertDialog(
              title: Text(
                'Usar: $nombre',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37474F),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disponible: $stockDisponible $unidad'),
                    const SizedBox(height: 12),

                    // Cantidad (textbox)
                    TextField(
                      controller: cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Cantidad a usar',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Actividad (combobox / spinner)
                    DropdownButtonFormField<String>(
                      value: actividadSeleccionada,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Actividad',
                        prefixIcon: Icon(Icons.construction),
                      ),
                      items: actividades
                          .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(
                          a,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => actividadSeleccionada = value!);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Fecha (calendario)
                    TextField(
                      controller: fechaController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Fecha de uso',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: seleccionarFecha,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Seleccionar fecha'),
                    ),
                    const SizedBox(height: 12),

                    // Prioridad (radiobutton)
                    const Text(
                      'Prioridad',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RadioListTile<String>(
                      title: const Text('Normal'),
                      value: 'Normal',
                      groupValue: prioridad,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setDialogState(() => prioridad = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Urgente'),
                      value: 'Urgente',
                      groupValue: prioridad,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setDialogState(() => prioridad = value!);
                      },
                    ),

                    // Requiere reposición (checkbox)
                    CheckboxListTile(
                      title: const Text('Requiere reposición inmediata'),
                      value: requiereReposicion,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        setDialogState(() => requiereReposicion = value!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37474F),
                  ),
                  onPressed: () {
                    final cantidad = int.tryParse(cantidadController.text);

                    if (cantidad == null || cantidad <= 0) {
                      _mostrarSnackBar('Ingresa una cantidad válida',
                          esError: true);
                      return;
                    }
                    if (cantidad > stockDisponible) {
                      _mostrarSnackBar(
                          'Cantidad supera el stock disponible ($stockDisponible)',
                          esError: true);
                      return;
                    }

                    final exito =
                    widget.onRegistrarSalida(codigo, cantidad);

                    if (exito) {
                      setState(() {
                        itemInventario['stock'] = stockDisponible - cantidad;
                        historialUsos.insert(0, {
                          'codigo': codigo,
                          'nombre': nombre,
                          'cantidad': cantidad,
                          'unidad': unidad,
                          'actividad': actividadSeleccionada,
                          'fecha': fechaController.text,
                          'prioridad': prioridad,
                          'requiereReposicion': requiereReposicion,
                        });
                      });
                      Navigator.pop(dialogContext);
                      _mostrarSnackBar(
                          'Uso registrado: -$cantidad $unidad de $nombre en "$actividadSeleccionada"');
                    } else {
                      _mostrarSnackBar('No se pudo registrar el uso',
                          esError: true);
                    }
                  },
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          color: const Color(0xFF37474F),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Registrar Uso', icon: Icon(Icons.build_circle)),
              Tab(text: 'Historial', icon: Icon(Icons.history)),
              Tab(text: 'Resumen', icon: Icon(Icons.pie_chart)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRegistrarUsoTab(),
              _buildHistorialTab(),
              _buildResumenTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- TAB 1: Registrar Uso ----------
  Widget _buildRegistrarUsoTab() {
    return Container(
      color: const Color(0xFFCFD8DC),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: inventario.length,
        itemBuilder: (context, index) {
          final item = inventario[index];
          final info = _catalogoDe(item['codigo']);
          final stock = item['stock'] as int;
          final nombre = info?['nombre'] ?? item['codigo'];
          final unidad = info?['unidad'] ?? '';
          final categoria = info?['categoria'] ?? '';
          final sinStock = stock <= 0;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  Text(
                    'Código: ${item['codigo']}  •  $categoria',
                    style:
                    const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Icon(Icons.inventory_2,
                          size: 16,
                          color: sinStock ? Colors.red[700] : Colors.black87),
                      const SizedBox(width: 6),
                      Text(
                        'Disponible: $stock $unidad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: sinStock ? Colors.red[700] : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        sinStock ? Colors.grey : const Color(0xFF37474F),
                      ),
                      icon: const Icon(Icons.build, color: Colors.white),
                      label: const Text('Usar Material',
                          style: TextStyle(color: Colors.white)),
                      onPressed:
                      sinStock ? null : () => _abrirDialogoUso(item),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- TAB 2: Historial ----------
  Widget _buildHistorialTab() {
    if (historialUsos.isEmpty) {
      return const Center(
        child: Text(
          'Aún no se ha registrado ningún uso de material.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Container(
      color: const Color(0xFFCFD8DC),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: historialUsos.length,
        itemBuilder: (context, index) {
          final uso = historialUsos[index];
          final esUrgente = uso['prioridad'] == 'Urgente';
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(
                Icons.build_circle,
                color: esUrgente ? Colors.red[700] : const Color(0xFF37474F),
              ),
              title: Text('${uso['nombre']}  (-${uso['cantidad']} ${uso['unidad']})'),
              subtitle: Text(
                'Actividad: ${uso['actividad']}\nFecha: ${uso['fecha']}  •  Prioridad: ${uso['prioridad']}'
                    '${uso['requiereReposicion'] == true ? '\n⚠ Requiere reposición' : ''}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  // ---------- TAB 3: Resumen ----------
  Widget _buildResumenTab() {
    if (historialUsos.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos suficientes para mostrar un resumen.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final Map<String, int> porActividad = {};
    int totalUsos = 0;
    for (final uso in historialUsos) {
      final actividad = uso['actividad'] as String;
      final cantidad = uso['cantidad'] as int;
      porActividad[actividad] = (porActividad[actividad] ?? 0) + cantidad;
      totalUsos += cantidad;
    }

    return Container(
      color: const Color(0xFFCFD8DC),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total de unidades usadas: $totalUsos',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Uso por actividad:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: porActividad.entries
                  .map(
                    (e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.construction,
                        color: Color(0xFF37474F)),
                    title: Text(e.key),
                    trailing: Text(
                      '${e.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}