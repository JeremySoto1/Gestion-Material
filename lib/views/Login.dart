import 'package:flutter/material.dart';

class MyHomePageLogin extends StatefulWidget {
  const MyHomePageLogin({super.key});

  @override
  State<MyHomePageLogin> createState() => _MyHomePageLoginState();
}

class _MyHomePageLoginState extends State<MyHomePageLogin> {
  final correoController = TextEditingController();
  final claveController = TextEditingController();

  final String correoValido = "jeremy@gmail.com";
  final String claveValida = "12345";

  void iniciarSesion() {
    String correo = correoController.text.trim();
    String clave = claveController.text.trim();

    if (correo.isEmpty || clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    if (correo == correoValido && clave == claveValida) {
      print("Acceso concedido");

      Navigator.pushNamed(context, '/principal');
    } else {
      print("Acceso negado");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correo o contraseña incorrectos")),
      );
    }
  }

  void registrarUsuario() {
    print("Va a registrar un nuevo usuario");

    Navigator.pushNamed(context, '/registro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              "https://tse1.mm.bing.net/th/id/OIP.GdGyCTet3mxZ0wCcB122WwHaEO?r=0&rs=1&pid=ImgDetMain&o=7&rm=3",
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(
                  "Soto Jeremy - Buenaventura Andrea - Faria Jean - Marquez Jean - Vera Luis",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                const Text(
                  "Login",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Correo electrónico",
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: claveController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Contraseña",
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: iniciarSesion,
                    child: const Text("Ingresar"),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: registrarUsuario,
                    child: const Text("Registrarse"),
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
