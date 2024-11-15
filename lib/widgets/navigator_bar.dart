import 'package:flutter/material.dart';


class CustomBottomBar extends StatelessWidget {
  final VoidCallback onCameraPressed;

  const CustomBottomBar({super.key, required this.onCameraPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.photo, color: Colors.green),
              onPressed: () {
                Navigator.pushNamed(context, '/gallery');
            }),
            IconButton(
              icon: Icon(Icons.home, color: Colors.green),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              }, // Navega para Home
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.green),
              onPressed: () {
                Navigator.pushNamed(context, '/gallery');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: onCameraPressed, // Função passada como parâmetro
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
