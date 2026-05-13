import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../database/db_helper.dart';
import '../services/storage_service.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (pickedFile == null) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Fotoğrafı Kırp',
            toolbarColor: const Color(0xFF6C63FF),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF6C63FF),
            backgroundColor: Colors.black,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Fotoğrafı Kırp',
            cancelButtonTitle: 'Vazgeç',
            doneButtonTitle: 'Tamam',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      setState(() {
        selectedImage = File(croppedFile.path);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotoğraf seçilirken bir hata oluştu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fotoğraf Ekle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Mekan fotoğrafını nereden almak istersin?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _buildSheetOption(
                icon: Icons.photo_camera_rounded,
                label: 'Kamera Aç',
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildSheetOption(
                icon: Icons.photo_library_rounded,
                label: 'Galeriden Seç',
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F4FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF6C63FF), size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSavePressed() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Mekan adı boş bırakılamaz.');
      return;
    }

    if (description.isEmpty) {
      _showSnackBar('Açıklama boş bırakılamaz.');
      return;
    }

    if (location.isEmpty) {
      _showSnackBar('Konum bilgisi boş bırakılamaz.');
      return;
    }

    setState(() {
      _isSaving = true;
      _isUploading = false;
      _uploadProgress = 0.0;
    });

    final currentUser = FirebaseAuth.instance.currentUser;

    try {
      if (currentUser == null) {
        await _savePlaceLocally(name: name, description: description);

        if (!context.mounted) return;

        _clearForm();
        _showSnackBar('Giriş yapılmadığı için yerel veritabanına kaydedildi.');
        return;
      }

      await _savePlaceOnline(
        currentUser: currentUser,
        name: name,
        description: description,
        location: location,
      );

      if (!context.mounted) return;

      _clearForm();
      _showSnackBar('Mekan buluta başarıyla kaydedildi.');
    } catch (_) {
      if (!context.mounted) return;

      if (currentUser == null) {
        _showSnackBar('Mekan kaydedilirken bir hata oluştu.');
        return;
      }

      try {
        await _savePlaceLocally(name: name, description: description);

        if (!context.mounted) return;

        _clearForm();
        _showSnackBar(
          'Bağlantı sorunu nedeniyle mekan yerel veritabanına kaydedildi.',
        );
      } catch (_) {
        if (!context.mounted) return;

        _showSnackBar('Mekan kaydedilirken bir hata oluştu.');
      }
    } finally {
      if (mounted) {
        _resetSavingState();
      }
    }
  }

  Future<void> _savePlaceOnline({
    required User currentUser,
    required String name,
    required String description,
    required String location,
  }) async {
    String imageUrl = '';
    final imageFile = selectedImage;

    if (imageFile != null) {
      if (mounted) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });
      }

      imageUrl = await StorageService.instance.uploadPostImage(
        imageFile: imageFile,
        userId: currentUser.uid,
        onProgress: (progress) {
          if (!mounted) return;

          setState(() {
            _uploadProgress = progress.clamp(0.0, 1.0).toDouble();
          });
        },
      );

      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }

    await FirebaseFirestore.instance.collection('Posts').add({
      'name': name,
      'description': description,
      'location': location,
      'date': Timestamp.now(),
      'imageUrl': imageUrl,
      'userId': currentUser.uid,
      'userEmail': currentUser.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'source': 'firebase_storage_form',
    });
  }

  Future<void> _savePlaceLocally({
    required String name,
    required String description,
  }) {
    final place = Place(
      name: name,
      description: description,
      imagePath: selectedImage?.path ?? '',
      date: DateTime.now().toIso8601String(),
    );

    return DbHelper.instance.insertPlace(place);
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _locationController.clear();

    if (!mounted) return;

    setState(() {
      selectedImage = null;
    });
  }

  void _resetSavingState() {
    setState(() {
      _isSaving = false;
      _isUploading = false;
      _uploadProgress = 0.0;
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
            if (_isUploading) ...[
              _buildUploadProgress(),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _isSaving ? null : _onSavePressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _saveButtonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _saveButtonText {
    if (_isUploading) return 'Yükleniyor...';
    if (_isSaving) return 'Kaydediliyor...';
    return 'Kaydet';
  }

  Widget _buildUploadProgress() {
    final percentage = (_uploadProgress.clamp(0.0, 1.0) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Fotoğraf yükleniyor: %$percentage',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: _uploadProgress.clamp(0.0, 1.0).toDouble(),
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return GestureDetector(
      onTap: _isSaving ? null : _showImageSourceSheet,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: selectedImage == null
            ? Container(
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
                    Icon(
                      Icons.photo_camera_rounded,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fotoğraf Ekle',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kamera veya galeriden seç',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.file(selectedImage!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: _isSaving ? null : _showImageSourceSheet,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
