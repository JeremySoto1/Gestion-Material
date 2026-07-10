import 'package:flutter/material.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  // Variables
  bool activarCuenta = false;

  String genero = "Masculino";
  String estadoCivil = "Soltero";

  int selectedIndex = 0;

  // Controllers
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contraseniaController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  // Calendario
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        fechaController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  // Limpiar formulario
  void limpiarFormulario() {
    setState(() {
      codigoController.clear();
      cedulaController.clear();
      nombreController.clear();
      apellidoController.clear();
      correoController.clear();
      contraseniaController.clear();
      fechaController.clear();

      activarCuenta = false;
      genero = "Masculino";
      estadoCivil = "Soltero";
    });
  }

  @override
  void dispose() {
    codigoController.dispose();
    cedulaController.dispose();
    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();
    contraseniaController.dispose();
    fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulario de Registro"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 380,
            child: Column(
              children: [
                // Código
                TextField(
                  controller: codigoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Código",
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),

                const SizedBox(height: 15),

                // Cédula
                TextField(
                  controller: cedulaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Cédula",
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),

                const SizedBox(height: 15),

                // Nombre
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Nombre",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 15),

                // Apellido
                TextField(
                  controller: apellidoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Apellido",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: 15),

                // Correo
                TextField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Correo",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 15),

                // Contraseña
                TextField(
                  controller: contraseniaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),

                const SizedBox(height: 15),

                // ComboBox
                DropdownButtonFormField<String>(
                  initialValue: estadoCivil,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "estadoCivil",
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Soltero", child: Text("Soltero")),
                    DropdownMenuItem(value: "Casado", child: Text("Casado")),
                    DropdownMenuItem(
                      value: "Divorciado",
                      child: Text("Divorciado"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      estadoCivil = value!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Fecha
                TextField(
                  controller: fechaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Fecha de Nacimiento",
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                ),

                const SizedBox(height: 10),

                OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Seleccionar Fecha"),
                ),

                const SizedBox(height: 20),

                // Radio Buttons
                const Text(
                  "Seleccione el género",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                RadioListTile<String>(
                  title: const Text("Masculino"),
                  value: "Masculino",
                  groupValue: genero,
                  onChanged: (value) {
                    setState(() {
                      genero = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  title: const Text("Femenino"),
                  value: "Femenino",
                  groupValue: genero,
                  onChanged: (value) {
                    setState(() {
                      genero = value!;
                    });
                  },
                ),

                const SizedBox(height: 10),

                // Switch
                SwitchListTile(
                  title: const Text("Activar cuenta"),
                  value: activarCuenta,
                  onChanged: (value) {
                    setState(() {
                      activarCuenta = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Botón Registrar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      debugPrint("===== DATOS REGISTRADOS =====");
                      debugPrint("Código: ${codigoController.text}");
                      debugPrint("Cédula: ${cedulaController.text}");
                      debugPrint("Nombre: ${nombreController.text}");
                      debugPrint("Apellido: ${apellidoController.text}");
                      debugPrint("Correo: ${correoController.text}");
                      debugPrint("Contraseña: ${contraseniaController.text}");
                      debugPrint("estadoCivil: $estadoCivil");
                      debugPrint("Género: $genero");
                      debugPrint("Fecha: ${fechaController.text}");
                      debugPrint("Cuenta Activa: $activarCuenta");
                    },
                    child: const Text(
                      "Registrar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Botón Borrar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: limpiarFormulario,
                    child: const Text(
                      "Borrar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
