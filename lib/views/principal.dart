import 'package:flutter/material.dart';
import 'uso_material.dart';
import 'catalogo.dart';
import 'inventario.dart';
import 'entrada_material.dart';
import 'reportes_page.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  int currentPageIndex = 0;

  final GlobalKey<InventarioPageState> inventarioKey =
      GlobalKey<InventarioPageState>();
  final GlobalKey<UsoMaterialPageState> usoMaterialKey =
      GlobalKey<UsoMaterialPageState>();

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

      EntradaMaterialPage(
        onRegistrarEntrada: registrarEntradaMaterial,
        onReverseEntrada: revertirEntradaMaterial,
      ),

      InventarioPage(key: inventarioKey),

      const CatalogoPage(),

      const ReportesPage(),

      UsoMaterialPage(
        key: usoMaterialKey,
        onRegistrarSalida: registrarSalidaMaterial,
      ),
    ];
  }

  bool registrarEntradaMaterial(String codigo, int cantidad, String obra) {
    final res =
        inventarioKey.currentState?.registrarEntrada(codigo, cantidad, obra) ??
        false;
    _sincronizarInventario();
    return res;
  }

  bool registrarSalidaMaterial(String codigo, int cantidad, String obra) {
    final res =
        inventarioKey.currentState?.registrarSalida(codigo, cantidad, obra) ??
        false;
    _sincronizarInventario();
    return res;
  }

  bool revertirEntradaMaterial(String codigo, int cantidad, String obra) {
    inventarioKey.currentState?.forzarAjusteStock(codigo, cantidad, obra);
    _sincronizarInventario();
    return true;
  }

  void _sincronizarInventario() {
    final inventarioActual = inventarioKey.currentState?.inventario;
    if (inventarioActual != null) {
      usoMaterialKey.currentState?.actualizarInventario(inventarioActual);
    }
  }

  static const List<String> _titulos = [
    'CONTROL DE USUARIO',
    'ENTRADA DE MATERIAL',
    'INVENTARIO',
    'CATÁLOGO DE MATERIALES',
    'REPORTES',
    'USO DE MATERIAL',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFD8DC),
      appBar: AppBar(
        title: Text(
          _titulos[currentPageIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF37474F),
        centerTitle: true,
      ),

      body: IndexedStack(index: currentPageIndex, children: paginas),

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
          NavigationDestination(icon: Icon(Icons.build), label: "Uso"),
        ],
      ),
    );
  }
}
