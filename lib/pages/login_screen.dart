import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/register_screen.dart'; // Asegúrate de importar RegisterScreen
import 'package:objetos_perdidos/pages/home_page.dart';
import 'package:objetos_perdidos/services/login_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Objetos Perdidos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Inicia con LoginScreen
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // Para mostrar un indicador de carga
  bool isLogin = true; // Determina si estamos en login o registro

  // Función para manejar el login
  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showError('Por favor, completa todos los campos');
      return;
    }

    // Llamar al método loginUser
    final result = await loginUser(email, password);

    if (result['success']) {
      // Guardar el token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);

      // Guardar la información del usuario
      final user = result['user'];
      await prefs.setString('user_name', user['username']);
      await prefs.setString('user_email', user['email']);
      await prefs.setString('user_phone', user['phone']);
      await prefs.setString('user_type', user['userType']);
      await prefs.setString('user_id', user['userId']); // Guardamos el userId

      // Redirigir a la página principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      _showError(result['message'] ?? 'Error desconocido');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Mostrar un diálogo de error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? 'Iniciar Sesión' : 'Registro',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController, // Asignar controlador
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController, // Asignar controlador
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator() // Mostrar indicador de carga
                  : ElevatedButton(
                      onPressed: handleLogin, // Llamar al login
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Cambiar la vista al registrar o login
                  if (isLogin) {
                    // Si estamos en Login, navegar a RegisterScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  } else {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  }
                },
                child: Text(
                  isLogin
                      ? '¿No tienes cuenta? Regístrate'
                      : '¿Ya tienes cuenta? Inicia sesión',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
