import 'package:flutter/material.dart';

class VetBookPage extends StatefulWidget {
  final Map<String, String> pet;

  const VetBookPage({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  _VetBookPageState createState() => _VetBookPageState();
}

class _VetBookPageState extends State<VetBookPage> {
  late List<Map<String, String>> records;

  @override
  void initState() {
    super.initState();
    records = _generateRecords(widget.pet['id']!);
  }

  List<Map<String, String>> _generateRecords(String petId) {
    // Simulazione di record in base all'ID del pet
    if (petId == '1') {
      return [
        {'prescription': 'Antibiotico', 'visitDate': '01/01/2024'},
        {'prescription': 'Vaccino', 'visitDate': '15/02/2024'},
      ];
    } else if (petId == '2') {
      return [
        {'prescription': 'Antinfiammatorio', 'visitDate': '05/03/2024'},
        {'prescription': 'Sverminazione', 'visitDate': '20/03/2024'},
      ];
    } else {
      return [];
    }
  }

  void _addRecord(String prescription, String visitDate) {
    setState(() {
      records.add({
        'prescription': prescription,
        'visitDate': visitDate,
      });
    });
  }

  void _deleteRecord(int index) {
    setState(() {
      records.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Libretto Veterinario di ${widget.pet['name']}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 244, 132, 34),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specie: ${widget.pet['type']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Text(
                        'Nessun dato disponibile per questo animale.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              record['prescription']!,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              'Data visita: ${record['visitDate']!}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteRecord(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRecordDialog(context);
        },
        backgroundColor: const Color.fromARGB(255, 244, 132, 34),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    String prescription = "";
    String visitDate = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aggiungi Prescrizione/Visita'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Prescrizione'),
                onChanged: (value) {
                  prescription = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                    labelText: 'Data visita (es. 08/12/2024)'),
                onChanged: (value) {
                  visitDate = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (prescription.isNotEmpty && visitDate.isNotEmpty) {
                  _addRecord(prescription, visitDate);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }
}
