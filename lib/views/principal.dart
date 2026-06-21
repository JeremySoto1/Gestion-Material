import 'package:flutter/material.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  int currentPageIndex = 0;

  final List<Widget> paginas = [
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

    const Center(
      child: Text(
        "INVENTARIO",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),

    const Center(
      child: Text(
        "CATÁLOGO",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),

    const Center(
      child: Text(
        "REPORTES",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
