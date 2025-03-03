import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy_tails/app/routes.dart';

class ProfiloPage extends StatelessWidget {
  const ProfiloPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Blocco con testo, immagine e pulsanti dentro un container
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Titolo del messaggio
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  'Per visualizzare o modificare le informazioni del tuo profilo accedi oppure crea un nuovo account.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Blocco immagine e pulsanti
                              _buildImageBlock(
                                context,
                                'assets/profile-setting.png',
                                [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.loginPage);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 244, 132, 34),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Accedi',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.registrationPage);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 244, 132, 34),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Registrati',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Metodo per costruire blocco immagine + pulsanti dinamici
  Widget _buildImageBlock(
      BuildContext context, String imagePath, List<Widget> buttons) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: 250,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 40),
        Column(
          children: buttons.map((button) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: button,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
