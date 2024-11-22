import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/risultatiRicerca_pagina.dart';
import 'package:intl/intl.dart'; // Per il formato della data del calendario

class CercaPage extends StatefulWidget {
  const CercaPage({Key? key}) : super(key: key);

  @override
  _CercaPageState createState() => _CercaPageState();
}

class _CercaPageState extends State<CercaPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedOption1;
  String? selectedOption2;
  DateTime? selectedDate;

  // Liste di opzioni per i dropdown
  final List<String> options1 = ['Cane', 'Gatto', 'Canarino'];
  final List<String> options2 = ['Avellino', 'Benevento', 'Salerno'];

  // Funzione per aprire il selettore di data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = DateTime(2020);
    final DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding esterno per separare dal bordo
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Posiziona all'inizio dello schermo
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity, // Per fare in modo che il Container prenda tutta la larghezza
              constraints: BoxConstraints(maxWidth: 600), // Limita la larghezza massima
              decoration: BoxDecoration(
                color: Colors.white, // Colore di sfondo del Container
                borderRadius: BorderRadius.circular(10), // Angoli arrotondati
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5), // Ombra più morbida
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown 1 (Animale) con icona
                      Row(
                        children: [
                          const Icon(Icons.pets, color: Colors.black),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedOption1,
                              decoration: const InputDecoration(
                                labelText: 'Animale',
                                border: OutlineInputBorder(),
                              ),
                              items: options1.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedOption1 = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Per favore, scegli un\'animale';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Dropdown 2 (Provincia) con icona
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.black),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedOption2,
                              decoration: const InputDecoration(
                                labelText: 'Provincia',
                                border: OutlineInputBorder(),
                              ),
                              items: options2.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedOption2 = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Per favore, scegli una provincia';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Calendario (DatePicker) con icona
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: TextEditingController(
                                    text: selectedDate == null
                                        ? ''
                                        : DateFormat('yyyy-MM-dd').format(selectedDate!),
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Data',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Per favore, seleziona una data';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Pulsante per inviare il form
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Processa i dati del form

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Elaborazione in corso...')),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RisultatiCercaPage()),
    );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Colore di sfondo (arancione)
                            foregroundColor: Colors.white, // Colore del testo (bianco)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Bordi leggermente arrotondati
                            ),
                            minimumSize: Size(double.infinity, 50), // Larghezza e altezza minime del pulsante
                          ),
                          child: const Text('Cerca'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
