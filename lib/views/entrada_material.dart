import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EntradaMaterialPage extends StatefulWidget {
  final bool Function(String codigo, int cantidad, String obra) onRegistrarEntrada;
  final bool Function(String codigo, int cantidad) onReverseEntrada;

  const EntradaMaterialPage({
    super.key,
    required this.onRegistrarEntrada,
    required this.onReverseEntrada,
  });

  @override
  State<EntradaMaterialPage> createState() => _EntradaMaterialPageState();
}

class _EntradaMaterialPageState extends State<EntradaMaterialPage> {
  List<Map<String, dynamic>> catalogo = [];
  List<Map<String, dynamic>> entradas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final catalogoJson =
        await rootBundle.loadString('assets/data/materiales.json');
    final List<dynamic> datosCatalogo = jsonDecode(catalogoJson);
    setState(() {
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

  DateTime _parseFecha(String fecha) {
    try {
      final partes = fecha.split('/');
      return DateTime(
        int.parse(partes[2]),
        int.parse(partes[1]),
        int.parse(partes[0]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _abrirFormularioEntrada({int? index}) async {
    final entradaExistente = index != null ? entradas[index] : null;
    final formKey = GlobalKey<FormState>();

    String? codigoSeleccionado = entradaExistente?['codigo'];
    final cantidadController = TextEditingController(
      text: entradaExistente != null ? '${entradaExistente['cantidad']}' : '',
    );
    final obraController = TextEditingController(
      text: entradaExistente?['obra'] ?? '',
    );
    final notaController = TextEditingController(
      text: entradaExistente?['nota'] ?? '',
    );

    DateTime fechaEntrada = entradaExistente != null
        ? _parseFecha(entradaExistente['fecha'])
        : DateTime.now();
    final fechaController = TextEditingController(
      text:
          '${fechaEntrada.day}/${fechaEntrada.month}/${fechaEntrada.year}',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> seleccionarFecha() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: fechaEntrada,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setDialogState(() {
                  fechaEntrada = picked;
                  fechaController.text =
                      '${picked.day}/${picked.month}/${picked.year}';
                });
              }
            }

            return AlertDialog(
              title: Text(
                entradaExistente == null
                    ? 'Nuevo Registro de Entrada'
                    : 'Editar Entrada',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37474F),
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCFD8DC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory,
                                  size: 16, color: Color(0xFF37474F)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entradaExistente!['nombre']} (${entradaExistente['codigo']})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: codigoSeleccionado,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Material',
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          items: catalogo.map<DropdownMenuItem<String>>((m) {
                            return DropdownMenuItem<String>(
                              value: m['codigo'],
                              child: Text(
                                '${m['codigo']} - ${m['nombre']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(
                                () => codigoSeleccionado = value);
                          },
                          validator: (value) =>
                              value == null ? 'Selecciona un material' : null,
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cantidadController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Cantidad',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        validator: (value) {
                          final cantidad = int.tryParse(value ?? '');
                          if (cantidad == null || cantidad <= 0) {
                            return 'Ingresa una cantidad válida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: obraController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Obra / Destino',
                          prefixIcon: Icon(Icons.construction),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'La obra es obligatoria'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: fechaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Fecha de entrada',
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
                      TextFormField(
                        controller: notaController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nota (opcional)',
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                    ],
                  ),
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
                    if (!formKey.currentState!.validate()) return;
                    if (codigoSeleccionado == null) {
                      _mostrarSnackBar('Selecciona un material',
                          esError: true);
                      return;
                    }

                    final cantidad = int.parse(cantidadController.text.trim());
                    final obra = obraController.text.trim();
                    final infoCatalogo =
                        _buscarEnCatalogo(codigoSeleccionado!);
                    final nombre =
                        infoCatalogo?['nombre'] ?? codigoSeleccionado!;
                    final unidad = infoCatalogo?['unidad'] ?? '';

                    if (index == null) {
                      final exito = widget.onRegistrarEntrada(
                          codigoSeleccionado!, cantidad, obra);
                      if (!exito) {
                        _mostrarSnackBar(
                            'No se pudo registrar la entrada',
                            esError: true);
                        return;
                      }

                      setState(() {
                        entradas.insert(0, {
                          'codigo': codigoSeleccionado,
                          'nombre': nombre,
                          'cantidad': cantidad,
                          'obra': obra,
                          'fecha': fechaController.text,
                          'unidad': unidad,
                          'nota': notaController.text.trim(),
                        });
                      });

                      Navigator.pop(dialogContext);
                      _mostrarSnackBar(
                          'Entrada registrada: +$cantidad $unidad de $nombre');
                    } else {
                      final entradaVieja = entradas[index];
                      final cantidadVieja =
                          entradaVieja['cantidad'] as int;
                      final diferencia = cantidad - cantidadVieja;

                      if (diferencia > 0) {
                        widget.onRegistrarEntrada(
                            codigoSeleccionado!, diferencia, obra);
                      } else if (diferencia < 0) {
                        widget.onReverseEntrada(
                            codigoSeleccionado!, -diferencia);
                      }

                      setState(() {
                        entradas[index] = {
                          'codigo': codigoSeleccionado,
                          'nombre': nombre,
                          'cantidad': cantidad,
                          'obra': obra,
                          'fecha': fechaController.text,
                          'unidad': unidad,
                          'nota': notaController.text.trim(),
                        };
                      });

                      Navigator.pop(dialogContext);
                      _mostrarSnackBar(
                          'Entrada actualizada: $nombre');
                    }
                  },
                  child: const Text('Guardar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarEliminar(int index) async {
    final entrada = entradas[index];
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar entrada'),
        content: Text(
            '¿Seguro que deseas eliminar la entrada de "${entrada['nombre']}" (${entrada['cantidad']} ${entrada['unidad']})?\n\nSe revertirá el stock del inventario.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      widget.onReverseEntrada(
          entrada['codigo'], entrada['cantidad'] as int);
      setState(() => entradas.removeAt(index));
      _mostrarSnackBar(
          'Entrada de "${entrada['nombre']}" eliminada');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFFCFD8DC),
      child: Stack(
        children: [
          entradas.isEmpty
              ? const Center(
                  child: Text(
                    'No hay entradas registradas.\nPresiona + para agregar una.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  itemCount: entradas.length,
                  itemBuilder: (context, index) {
                    return _EntradaCard(
                      entrada: entradas[index],
                      onEditar: () => _abrirFormularioEntrada(index: index),
                      onEliminar: () => _confirmarEliminar(index),
                    );
                  },
                ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF37474F),
              onPressed: () => _abrirFormularioEntrada(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Nuevo registro',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntradaCard extends StatelessWidget {
  final Map<String, dynamic> entrada;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _EntradaCard({
    required this.entrada,
    required this.onEditar,
    required this.onEliminar,
  });

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF78909C)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entrada['nombre'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF37474F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Código: ${entrada['codigo']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF546E7A),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF37474F)),
                  tooltip: 'Editar entrada',
                  onPressed: onEditar,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[700]),
                  tooltip: 'Eliminar entrada',
                  onPressed: onEliminar,
                ),
              ],
            ),
            const Divider(height: 16),
            _infoRow(Icons.add_shopping_cart, 'Cantidad',
                '${entrada['cantidad']} ${entrada['unidad']}'),
            _infoRow(Icons.construction, 'Obra', entrada['obra']),
            _infoRow(Icons.calendar_month, 'Fecha', entrada['fecha']),
            if (entrada['nota'] != null &&
                (entrada['nota'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Nota: ${entrada['nota']}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
