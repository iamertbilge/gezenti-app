import 'package:flutter/material.dart';

import '../database/db_helper.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mekan adı boş bırakılamaz.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Açıklama boş bırakılamaz.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konum bilgisi boş bırakılamaz.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final place = Place(
      name: name,
      description: description,
      imagePath: '',
      date: DateTime.now().toIso8601String(),
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await DbHelper.instance.insertPlace(place);

      if (!context.mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Mekan yerel veritabanına kaydedildi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _nameController.clear();
      _descriptionController.clear();
      _locationController.clear();
    } catch (_) {
      if (!context.mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Mekan kaydedilirken bir hata oluştu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Mekan Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoPlaceholder(),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _nameController,
              label: 'Mekan Adı',
              icon: Icons.place,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _descriptionController,
              label: 'Açıklama',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _locationController,
              label: 'Konum Bilgisi',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _onSavePressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 48, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            'Fotoğraf Ekle',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
