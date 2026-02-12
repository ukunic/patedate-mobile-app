import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/app_exceptions.dart';
import '../data/pets_repository.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _repo = PetsRepository();

  final _name = TextEditingController();
  final _type = TextEditingController();
  final _ageMonths = TextEditingController();
  final _city = TextEditingController();
  final _about = TextEditingController();

  String? _gender; // Male/Female
  File? _photoFile;
  bool _loading = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xfile == null) return;
    setState(() => _photoFile = File(xfile.path));
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final type = _type.text.trim();

    if (name.isEmpty || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Type are required')),
      );
      return;
    }

    int? age;
    final ageText = _ageMonths.text.trim();
    if (ageText.isNotEmpty) {
      age = int.tryParse(ageText);
    }

    try {
      setState(() => _loading = true);

      await _repo.addPet(
        name: name,
        type: type,
        photoFile: _photoFile,
        ageMonths: age,
        gender: _gender,
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        about: _about.text.trim().isEmpty ? null : _about.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } on AppException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: _loading ? null : _pickPhoto,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                  color: Colors.white,
                ),
                child: _photoFile == null
                    ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 36),
                      SizedBox(height: 8),
                      Text('Tap to add photo (optional)'),
                    ],
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    _photoFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _type,
              decoration: const InputDecoration(
                labelText: 'Type * (Cat, Dog, etc.)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageMonths,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age (months) (optional)',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender (optional)'),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: _loading ? null : (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _about,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'About (optional)'),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                )
                    : const Text('Save Pet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
