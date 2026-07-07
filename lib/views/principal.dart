import 'package:flutter/material.dart';
import 'catalogo.dart';
import 'inventario.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  int currentPageIndex = 0;

  final GlobalKey<InventarioPageState> inventarioKey =
      GlobalKey<InventarioPageState>();

  late final List<Widget> paginas;

  @override
  void initState() {
    super.initState();
    paginas = [
      const Center(
        child: Text(
          "CONTROL DE USUARIO",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      const Center(
        child: Text(
          "ENTRADA MATERIAL",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      InventarioPage(key: inventarioKey),

      const CatalogoPage(),

      const Center(
        child: Text(
          "REPORTES",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  bool registrarEntradaMaterial(String codigo, int cantidad, String obra) {
    return inventarioKey.currentState?.registrarEntrada(codigo, cantidad, obra) ?? false;
  }
  bool registrarSalidaMaterial(String codigo, int cantidad) {
    return inventarioKey.currentState?.registrarSalida(codigo, cantidad) ?? false;
  }

  static const List<String> _titulos = [
    'CONTROL DE USUARIO',
    'ENTRADA DE MATERIAL',
    'INVENTARIO',
    'CATÁLOGO DE MATERIALES',
    'REPORTES',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFD8DC),
      appBar: AppBar(
        title: Text(
          _titulos[currentPageIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF37474F),
        centerTitle: true,
      ),
      body: paginas[currentPageIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people), label: "Usuarios"),
          NavigationDestination(icon: Icon(Icons.add_box), label: "Entrada"),
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: "Inventario",
          ),
          NavigationDestination(icon: Icon(Icons.menu_book), label: "Catálogo"),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: "Reportes"),
        ],
      ),
    );
  }
}
