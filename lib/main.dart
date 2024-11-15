import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/image_gallery_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Cria o diretório de imagens antes de executar o app
  try {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectoryPath = '${directory.path}/images';
    final imageDirectory = Directory(imageDirectoryPath);

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }
  } catch (e) {
    print('Erro ao criar o diretório de imagens: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/gallery': (context) => ImageGalleryScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
