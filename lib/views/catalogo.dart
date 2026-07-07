import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  List<dynamic> materiales = [];
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
      materiales = datos;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFCFD8DC),
      child: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: materiales.length,
              itemBuilder: (context, index) {
                final material = materiales[index];
                return _MaterialCard(material: material);
              },
            ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;

  const _MaterialCard({required this.material});

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
