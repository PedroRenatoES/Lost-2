import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:objetos_perdidos/services/posts_create.dart';
import 'package:objetos_perdidos/pages/home_page.dart'; // Importa la pantalla de inicio

class CreatePublicationScreen extends StatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  State<CreatePublicationScreen> createState() =>
      _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends State<CreatePublicationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? base64Image; // Para almacenar la imagen en base64
  bool isLoading = false;

  // Método para manejar la creación de la publicación
  Future<void> handleCreatePublication() async {
    setState(() {
      isLoading = true;
    });

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty || base64Image == null) {
      setState(() {
        isLoading = false;
      });
      _showError('Por favor, completa todos los campos');
      return;
    }

    final result = await createPublication(name, description, base64Image!);

    if (result['success']) {
      _showSuccess(result['message']);
    } else {
      _showError(result['message']);
    }

    setState(() {
      isLoading = false;
    });
  }

  // Mostrar un diálogo de éxito
  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
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

  // Método para seleccionar y convertir la imagen a Base64
  Future<void> pickImage() async {
    // Abrir el selector de archivos
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Solo permite imágenes
    );

    if (result != null) {
      // Obtener el archivo seleccionado
      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes != null) {
        // Convertir a Base64
        setState(() {
          base64Image = base64Encode(Uint8List.fromList(bytes));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crea una nueva publicación',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la publicación',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Botón para seleccionar imagen
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 16),
              // Mostrar el nombre del archivo seleccionado (si hay)
              if (base64Image != null)
                const Text('Imagen seleccionada', style: TextStyle(color: Colors.green)),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator()) // Mostrar carga
                  : ElevatedButton(
                      onPressed: handleCreatePublication,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Crear Publicación'),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const HomeScreen()), // Regresa a la pantalla de inicio
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Volver a la pantalla de inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
