import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageGalleryScreen extends StatefulWidget {
  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  List<File> _processedImages = [];

  // Lista de doenças associadas às imagens
  List<List<String>> _imageDiseases = [
    ['Rust', 'Phoma'],  // Doenças para a primeira imagem
    ['Rust', 'Phoma'],  // Doenças para a segunda imagem
    // Adicione mais conforme necessário
  ];

  @override
  void initState() {
    super.initState();
    _loadProcessedImages();
  }

  // Carrega as imagens diagnosticadas da pasta 'results'
  Future<void> _loadProcessedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final resultsDir = Directory('${directory.path}/results');

    if (!await resultsDir.exists()) {
      await resultsDir.create(recursive: true);
    }

    final files = resultsDir.listSync();
    List<File> images = [];

    for (var file in files) {
      if (_isImage(file.path)) {
        images.add(File(file.path));
      }
    }

    setState(() {
      _processedImages = images;
    });
  }

  // Verifica se o arquivo é uma imagem
  bool _isImage(String path) {
    final extensions = ['.jpg', '.jpeg', '.png'];
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  // Exclui a imagem selecionada
  void _deleteSelectedImage(int index) {
    setState(() {
      _processedImages[index].deleteSync();
      _processedImages.removeAt(index);
      _imageDiseases.removeAt(index);  // Remover as doenças associadas
    });
  }

  // Exibe o pop-up com os detalhes da imagem
  void _showImageDetails(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                _processedImages[index],
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Text(
                'Doenças Identificadas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              for (var disease in _imageDiseases[index])
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeria de Diagnósticos'),
      ),
      body: _processedImages.isEmpty
          ? Center(child: Text('Nenhuma imagem processada encontrada.'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: _processedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageDetails(index),  // Exibe os detalhes ao tocar
                      child: Image.file(
                        _processedImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSelectedImage(index),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
