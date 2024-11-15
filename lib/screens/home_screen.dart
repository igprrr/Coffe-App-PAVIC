import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  List<File> _recentImages = [];
  List<String> _diseases = []; // Lista para armazenar as doenças diagnosticadas

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
  }

  Future<void> _loadRecentImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final resultsDir = Directory('${directory.path}/results');

    if (!await resultsDir.exists()) {
      await resultsDir.create(recursive: true);
    }

    final files = resultsDir.listSync();
    List<File> images = [];

    for (var file in files) {
      if (_isImage(file.path)) {
        final imageFile = File(file.path);
        if (await imageFile.length() > 0) {
          images.add(imageFile);
        }
      }
    }

    setState(() {
      _recentImages = images;
    });
  }

  bool _isImage(String path) {
    final extensions = ['.jpg', '.jpeg', '.png'];
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Diagnóstico'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!)
                : Container(),
            SizedBox(height: 10),
            Text('Deseja enviar esta imagem para diagnóstico?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendImageToServer(_selectedImage!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendImageToServer(File image) async {
    // Exibe a mensagem de envio de imagem
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enviando imagem para diagnóstico...')),
    );

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://172.20.10.2:5000/diagnose'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();

      final directory = await getApplicationDocumentsDirectory();
      final resultsDir = Directory('${directory.path}/results');
      if (!await resultsDir.exists()) await resultsDir.create(recursive: true);

      final imagePath = '${resultsDir.path}/processed_${path.basename(image.path)}';
      final processedImage = File(imagePath)..writeAsBytesSync(responseData);

      // Exibe a mensagem de diagnóstico concluído antes de exibir a imagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Diagnóstico concluído com sucesso!')),
      );

      // Espera a mensagem de sucesso desaparecer antes de exibir a imagem
      await Future.delayed(Duration(seconds: 2));

      // Atualiza o estado da lista de imagens recentes e doenças detectadas
      setState(() {
        _recentImages.add(processedImage);
        _diseases = ['Rust', 'Phoma']; // Exemplo de doenças detectadas
      });

      // Exibe o pop-up com a imagem processada e as doenças detectadas
      _showImageDetails(processedImage);

    } else {
      _showErrorDialog();
    }
  }

  void _showImageDetails(File processedImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(processedImage),
              SizedBox(height: 20),
              Text(
                'Doenças Identificadas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              for (var disease in _diseases)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(disease),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o pop-up
                },
                child: Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text('Erro ao processar a imagem.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
@override
@override
Widget build(BuildContext context) {
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
      color: Colors.white, // Garantir que o fundo da tela principal seja branco
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Escolha uma imagem da galeria ou capture utilizando sua câmera para que o modelo possa realizar o diagnóstico.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 20, 19, 19)),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _pickImage(fromCamera: false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Importar da Galeria', style: TextStyle(color: Colors.white)),
              
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(fromCamera: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Capturar Imagem', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: BottomAppBar(
  shape: CircularNotchedRectangle(),
  notchMargin: 8.0,
  color: Color(0xFF1E3A8A), // Azul escuro para o fundo da BottomAppBar
  elevation: 10, // Sombra para dar profundidade
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
}
