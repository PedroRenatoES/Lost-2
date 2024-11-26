import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> createPublication(
    String name, String description, String image) async {
  final url =
      Uri.parse('$ngrokLink/api/lost-items/create'); // URL de tu endpoint

  // Obtener el token y el userId desde SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? userId = prefs.getString('user_id');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Agregar el token para autorización
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'image': image, // Por ahora solo string, en el futuro puede ser base64
        'user': userId, // Enviar el ID del usuario
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': 'Publicación creada con éxito',
        'publication': data['publication'],
      };
    } else {
      print(response.body);
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión',
    };
  }
}
