import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  List<Map<String, dynamic>> materiales = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
  }

  Future<void> _cargarMateriales() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/materiales.json');
    final List<dynamic> datos = jsonDecode(jsonString);
    setState(() {
      materiales = datos.cast<Map<String, dynamic>>();
      cargando = false;
    });
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

  bool _codigoRepetido(String codigo, {int? indiceActual}) {
    for (int i = 0; i < materiales.length; i++) {
      if (indiceActual != null && i == indiceActual) continue;
      if (materiales[i]['codigo'] == codigo) return true;
    }
    return false;
  }

  Future<void> _abrirFormularioMaterial({int? index}) async {
    final materialExistente = index != null ? materiales[index] : null;
    final formKey = GlobalKey<FormState>();

    final codigoController =
        TextEditingController(text: materialExistente?['codigo'] ?? '');
    final nombreController =
        TextEditingController(text: materialExistente?['nombre'] ?? '');
    final categoriaController =
        TextEditingController(text: materialExistente?['categoria'] ?? '');
    final precioController = TextEditingController(
        text: materialExistente != null
            ? '${materialExistente['precio']}'
            : '');
    final stockMinimoController = TextEditingController(
        text: materialExistente != null
            ? '${materialExistente['stockMinimo']}'
            : '');
    final unidadController =
        TextEditingController(text: materialExistente?['unidad'] ?? '');
    final descripcionController =
        TextEditingController(text: materialExistente?['descripcion'] ?? '');
    final proveedorController =
        TextEditingController(text: materialExistente?['proveedor'] ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            materialExistente == null ? 'Nuevo Material' : 'Editar Material',
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
                  TextFormField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Código',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El código es obligatorio';
                      }
                      if (_codigoRepetido(value.trim(), indiceActual: index)) {
                        return 'Ya existe un material con ese código';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nombre',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'El nombre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: categoriaController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Categoría',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'La categoría es obligatoria'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: precioController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Precio',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      final precio = double.tryParse(value ?? '');
                      if (precio == null || precio <= 0) {
                        return 'Ingresa un precio válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: stockMinimoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Stock Mínimo',
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    validator: (value) {
                      final stockMinimo = int.tryParse(value ?? '');
                      if (stockMinimo == null || stockMinimo < 0) {
                        return 'Ingresa un stock mínimo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: unidadController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Unidad',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'La unidad es obligatoria'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descripcionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Descripción',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'La descripción es obligatoria'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: proveedorController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Proveedor',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'El proveedor es obligatorio'
                        : null,
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
              style:
                  ElevatedButton.styleFrom(backgroundColor: const Color(0xFF37474F)),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final nuevoMaterial = {
                  'codigo': codigoController.text.trim(),
                  'nombre': nombreController.text.trim(),
                  'categoria': categoriaController.text.trim(),
                  'precio': double.parse(precioController.text),
                  'stockMinimo': int.parse(stockMinimoController.text),
                  'unidad': unidadController.text.trim(),
                  'descripcion': descripcionController.text.trim(),
                  'proveedor': proveedorController.text.trim(),
                };

                setState(() {
                  if (index == null) {
                    materiales.add(nuevoMaterial);
                  } else {
                    materiales[index] = nuevoMaterial;
                  }
                });

                Navigator.pop(dialogContext);
                _mostrarSnackBar(index == null
                    ? 'Material "${nuevoMaterial['nombre']}" agregado'
                    : 'Material "${nuevoMaterial['nombre']}" actualizado');
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarEliminar(int index) async {
    final material = materiales[index];
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar material'),
        content: Text(
            '¿Seguro que deseas eliminar "${material['nombre']}" del catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      setState(() => materiales.removeAt(index));
      _mostrarSnackBar('Material "${material['nombre']}" eliminado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFCFD8DC),
      child: cargando
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  itemCount: materiales.length,
                  itemBuilder: (context, index) {
                    return _MaterialCard(
                      material: materiales[index],
                      onEditar: () => _abrirFormularioMaterial(index: index),
                      onEliminar: () => _confirmarEliminar(index),
                    );
                  },
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.extended(
                    backgroundColor: const Color(0xFF37474F),
                    onPressed: () => _abrirFormularioMaterial(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Nuevo material',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _MaterialCard({
    required this.material,
    required this.onEditar,
    required this.onEliminar,
  });

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
                      // Nombre — información principal en negrita
                      Text(
                        material['nombre'],
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF37474F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Código — información principal en negrita
                      Text(
                        'Código: ${material['codigo']}',
                        textAlign: TextAlign.left,
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
                  tooltip: 'Editar material',
                  onPressed: onEditar,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[700]),
                  tooltip: 'Eliminar material',
                  onPressed: onEliminar,
                ),
              ],
            ),
            const Divider(height: 16),
            _infoRow(Icons.category, 'Categoría', material['categoria']),
            _infoRow(Icons.inventory_2, 'Stock Mínimo',
                '${material['stockMinimo']} ${material['unidad']}'),
            _infoRow(Icons.attach_money, 'Precio',
                '\$${material['precio'].toStringAsFixed(2)} / ${material['unidad']}'),
            _infoRow(Icons.store, 'Proveedor', material['proveedor']),
            const SizedBox(height: 8),
            Text(
              material['descripcion'],
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

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
}
