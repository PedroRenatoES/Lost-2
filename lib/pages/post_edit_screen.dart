import 'package:flutter/material.dart';
import 'package:objetos_perdidos/services/posts_update.dart';
import 'package:objetos_perdidos/services/posts_delete.dart';
import 'package:objetos_perdidos/services/main_class.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  String _found = 'false';
  String _status = 'pendiente';

  @override
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.post.lostItem.name);
    _descriptionController =
        TextEditingController(text: widget.post.lostItem.description);
    _imageController = TextEditingController(text: widget.post.lostItem.image);

    // Si los valores de found y status no están inicializados correctamente:
    _found = widget.post.lostItem.found ? 'true' : 'false';
    _status = widget.post.status;
  }

  Future<void> _updateLostItem() async {
    try {
      print('Datos antes de enviar:');
      print('Name: ${_nameController.text}');
      print('Description: ${_descriptionController.text}');
      print('Image: ${_imageController.text}');
      print('Found: ${_found == 'true'}');
      print('Status: $_status');

      await updateLostItem(
        lostItemId: widget.post.lostItem.id,
        name: _nameController.text,
        description: _descriptionController.text,
        image: _imageController.text,
        found: _found == 'true',
        status: _status,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objeto perdido actualizado con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Future<void> _deletePost() async {
    try {
      await deletePost(widget.post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación eliminada con éxito')),
      );
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Publicación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'URL de la Imagen'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _found,
              onChanged: (value) => setState(() => _found = value!),
              items: const [
                DropdownMenuItem(value: 'true', child: Text('Encontrado')),
                DropdownMenuItem(value: 'false', child: Text('Perdido')),
              ],
              decoration: const InputDecoration(labelText: 'Estado del objeto'),
            ),
            DropdownButtonFormField<String>(
              value: _status,
              onChanged: (value) => setState(() => _status = value!),
              items: const [
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(
                    value: 'encontrado', child: Text('Encontrado')),
              ],
              decoration:
                  const InputDecoration(labelText: 'Estado de la publicación'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver al Inicio'),
                ),
                ElevatedButton(
                  onPressed: _updateLostItem,
                  child: const Text('Guardar Cambios'),
                ),
                ElevatedButton(
                  onPressed: _deletePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Eliminar Publicación'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
