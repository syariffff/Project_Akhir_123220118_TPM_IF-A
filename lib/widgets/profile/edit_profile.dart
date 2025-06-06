import 'dart:io';
import 'package:finalproject/theme/theme.dart';
import 'package:finalproject/widgets/scaffold/custom_scaffold2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool agreePersonalData = true;
  File? _pickedImage;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  // Fungsi untuk mengambil data pengguna dari SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';
    String email = prefs.getString('email') ?? '';
    String profileImage = prefs.getString('profileImageUrl') ?? '';

    setState(() {
      _nameController.text = username;
      _emailController.text = email;
      _currentImagePath = profileImage;
      
      // Jika ada path gambar yang tersimpan dan file masih ada
      if (profileImage.isNotEmpty && profileImage != 'assets/images/leehan.jpg') {
        File imageFile = File(profileImage);
        if (imageFile.existsSync()) {
          _pickedImage = imageFile;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Kompres gambar untuk menghemat storage
    );
    if (imageFile != null) {
      setState(() {
        _pickedImage = File(imageFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the processing of personal data'),
        ),
      );
      return;
    }

    // Simpan data ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _nameController.text);
    await prefs.setString('email', _emailController.text);
    
    // Simpan path gambar jika ada
    if (_pickedImage != null) {
      await prefs.setString('profileImageUrl', _pickedImage!.path);
    } else if (_currentImagePath != null && _currentImagePath!.isNotEmpty) {
      // Tetap gunakan gambar yang sudah ada
      await prefs.setString('profileImageUrl', _currentImagePath!);
    } else {
      // Gunakan gambar default
      await prefs.setString('profileImageUrl', 'assets/images/leehan.jpg');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil disimpan'))
    );
    
    // Kembali ke halaman sebelumnya dengan hasil true untuk menandakan data berubah
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    
    if (_pickedImage != null) {
      // Gambar yang baru dipilih
      imageWidget = CircleAvatar(
        radius: 56,
        backgroundImage: FileImage(_pickedImage!),
      );
    } else if (_currentImagePath != null && 
               _currentImagePath!.isNotEmpty && 
               _currentImagePath != 'assets/images/leehan.jpg') {
      // Gambar yang sudah tersimpan sebelumnya
      File existingImage = File(_currentImagePath!);
      if (existingImage.existsSync()) {
        imageWidget = CircleAvatar(
          radius: 56,
          backgroundImage: FileImage(existingImage),
        );
      } else {
        // File tidak ada, gunakan default
        imageWidget = const CircleAvatar(
          radius: 56,
          backgroundImage: AssetImage('assets/images/leehan.jpg'),
        );
      }
    } else {
      // Gambar default
      imageWidget = const CircleAvatar(
        radius: 56,
        backgroundImage: AssetImage('assets/images/leehan.jpg'),
      );
    }

    return CustomScaffold2(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Image.asset('assets/logo/back.png', width: 35, height: 35),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      imageWidget,
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: lightColorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    hintText: 'Enter Nama',
                    hintStyle: const TextStyle(color: Colors.black26),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter Email',
                    hintStyle: const TextStyle(color: Colors.black26),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightColorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simpan', style: TextStyle(fontSize: 16)),
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