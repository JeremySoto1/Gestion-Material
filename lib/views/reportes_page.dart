import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  List<Map<String, dynamic>> materiales = [];
  List<Map<String, dynamic>> inventario = [];
  List<Map<String, dynamic>> movimientos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      print("Cargando materiales...");
      final materialesJson = await rootBundle.loadString(
        "assets/data/materiales.json",
      );

      print("Materiales OK");

      print("Cargando inventario...");
      final inventarioJson = await rootBundle.loadString(
        "assets/data/inventario.json",
      );

      print("Inventario OK");

      print("Cargando movimientos...");
      final movimientosJson = await rootBundle.loadString(
        "assets/data/movimientos.json",
      );

      print("Movimientos OK");

      setState(() {
        materiales = List<Map<String, dynamic>>.from(
          jsonDecode(materialesJson),
        );
        inventario = List<Map<String, dynamic>>.from(
          jsonDecode(inventarioJson),
        );
        movimientos = List<Map<String, dynamic>>.from(
          jsonDecode(movimientosJson),
        );
        cargando = false;
      });
    } catch (e, s) {
      print("ERROR: $e");
      print(s);

      setState(() {
        cargando = false;
      });
    }
  }

  Map<String, dynamic>? obtenerInventario(String codigo) {
    try {
      return inventario.firstWhere((e) => e["codigo"] == codigo);
    } catch (_) {
      return null;
    }
  }

  String obtenerNombre(String codigo) {
    try {
      return materiales.firstWhere((e) => e["codigo"] == codigo)["nombre"];
    } catch (_) {
      return codigo;
    }
  }

  int totalStockBajo() {
    int contador = 0;

    for (var material in materiales) {
      final inv = obtenerInventario(material["codigo"]);

      if (inv == null) continue;

      if (inv["stock"] < material["stockMinimo"]) {
        contador++;
      }
    }

    return contador;
  }

  int totalMovimientos() {
    return movimientos.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFCFD8DC),
      child: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "REPORTES",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _ResumenCard(
                          titulo: "Materiales",
                          valor: materiales.length.toString(),
                          icono: Icons.inventory,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _ResumenCard(
                          titulo: "Stock Bajo",
                          valor: totalStockBajo().toString(),
                          icono: Icons.warning_amber,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ResumenCard(
                          titulo: "Movimientos",
                          valor: totalMovimientos().toString(),
                          icono: Icons.swap_horiz,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _ResumenCard(
                          titulo: "Alertas",
                          valor: totalStockBajo().toString(),
                          icono: Icons.notifications_active,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Inventario",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: materiales.length,
                    itemBuilder: (context, index) {
                      final material = materiales[index];

                      final inv = obtenerInventario(material["codigo"]);

                      final stock = inv == null ? 0 : inv["stock"];

                      final bool bajo = stock < material["stockMinimo"];

                      return _InventarioCard(
                        material: material,
                        stock: stock,
                        bajo: bajo,
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Alertas",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  ...materiales.map((material) {
                    final inv = obtenerInventario(material["codigo"]);

                    if (inv == null) return const SizedBox();

                    final stock = inv["stock"];

                    if (stock >= material["stockMinimo"]) {
                      return const SizedBox();
                    }

                    return _AlertaCard(
                      nombre: material["nombre"],
                      stock: stock,
                      minimo: material["stockMinimo"],
                    );
                  }).toList(),

                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Uso de materiales",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movimientos.length,
                    itemBuilder: (context, index) {
                      final movimiento = movimientos[index];

                      return _MovimientoCard(
                        nombre: obtenerNombre(movimiento["codigo"]),
                        fecha: movimiento["fecha"],
                        cantidad: movimiento["cantidad"],
                        tipo: movimiento["tipo"],
                        obra: movimiento["obra"],
                        uso: movimiento["uso"],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _ResumenCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icono, size: 38, color: color),

            const SizedBox(height: 8),

            Text(
              valor,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            Text(titulo, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _InventarioCard extends StatelessWidget {
  final Map<String, dynamic> material;
  final int stock;
  final bool bajo;

  const _InventarioCard({
    required this.material,
    required this.stock,
    required this.bajo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              material["nombre"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.inventory),

                const SizedBox(width: 8),

                Text("Stock actual : $stock"),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.storage),

                const SizedBox(width: 8),

                Text("Stock mínimo : ${material["stockMinimo"]}"),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: bajo ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                bajo ? "⚠ STOCK BAJO" : "✓ DISPONIBLE",
                style: TextStyle(
                  color: bajo ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final String nombre;
  final int stock;
  final int minimo;

  const _AlertaCard({
    required this.nombre,
    required this.stock,
    required this.minimo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: Colors.red),

        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text("Stock actual: $stock\nStock mínimo: $minimo"),
      ),
    );
  }
}

class _MovimientoCard extends StatelessWidget {
  final String nombre;
  final String fecha;
  final String tipo;
  final int cantidad;
  final String obra;
  final String uso;

  const _MovimientoCard({
    required this.nombre,
    required this.fecha,
    required this.tipo,
    required this.cantidad,
    required this.obra,
    required this.uso,
  });

  @override
  Widget build(BuildContext context) {
    final bool salida = tipo.toUpperCase() == "SALIDA";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  salida ? Icons.arrow_upward : Icons.arrow_downward,
                  color: salida ? Colors.red : Colors.green,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF37474F),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: salida ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tipo,
                    style: TextStyle(
                      color: salida ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            _dato(Icons.calendar_month, "Fecha", fecha),

            _dato(Icons.inventory_2, "Cantidad", cantidad.toString()),

            _dato(Icons.location_city, "Obra", obra),

            _dato(Icons.construction, "Uso", uso),
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icono, size: 18, color: Colors.blueGrey),

          const SizedBox(width: 8),

          Text(
            "$titulo: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
