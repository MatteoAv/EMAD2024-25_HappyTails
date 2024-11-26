import 'package:flutter/material.dart';



class ProfiloPetsitter extends StatelessWidget {
  const ProfiloPetsitter({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        title: const Text('Pagina Pet Sitter'),
      ),
    );
  }

}
