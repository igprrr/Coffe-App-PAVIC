import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
        _nameController.text = user.displayName ?? ''; // Carrega o nome do usuário
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
      title: Image.asset(
        'assets/logo1.png', // Caminho para a logo
        height: 40,
      ),
      backgroundColor: Colors.white, // Garantir que o fundo seja branco
      centerTitle: true,
      ),
      body: Container(
  color: Colors.white, // Definindo o fundo branco
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Column(
      children: [
        SizedBox(height: 16),
        // Imagem de perfil
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : user?.photoURL != null
                    ? NetworkImage(user!.photoURL!) // Carrega a foto do usuário
                    : null,
            child: _profileImage == null && user?.photoURL == null
                ? Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                : null,
          ),
        ),
        SizedBox(height: 16),
        // Campo de nome
        _buildTextField("Nome", _nameController, true),
        SizedBox(height: 16),
        // Campo de e-mail
        _buildTextField("E-mail", _emailController, true),
        SizedBox(height: 24),
        // Botão para logout
        ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: Size(double.infinity, 48),
          ),
          child: Text(
            'Logout',
            style: TextStyle(
              color: Colors.white, // Define a cor do texto
              fontSize: 18, // Opcional: ajusta o tamanho do texto
            ),
          ),
        ),
      ],
    ),
  ),
),

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Color(0xFF1E3A8A),
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Image.asset('assets/gallery_icon.png', width: 30, height: 30),
              onPressed: () => Navigator.pushNamed(context, '/gallery'),
            ),
            IconButton(
              icon: Image.asset('assets/home_icon.png', width: 30, height: 30),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
            IconButton(
              icon: Image.asset('assets/profile_icon.png', width: 30, height: 30),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir campos de texto
  Widget _buildTextField(String label, TextEditingController controller, bool isReadOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          readOnly: isReadOnly,
        ),
      ],
    );
  }
}
