import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR code application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'QR code application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, String>> _fields = [];
  final List<String> _fieldTypes = ['Nom', 'Prénom', 'CIN', 'Email'];

  void _addField(String type) {
    setState(() {
      _fields.add({'type': type, 'value': ''});
    });
  }

  // Récupération des données pour le QR Code
  String _getTextForQRCode() {
    StringBuffer textBuffer = StringBuffer();

    for (var field in _fields) {
      String value = field['value']!;
      textBuffer.write('${field['type']}: $value\n');
    }

    return textBuffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // Ajouter une marge autour de la page
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Centrer verticalement
          children: [
            const Text(
              'Remplissez les champs :',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  // Texte de section plus grand
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _fields.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),  // Marges autour des champs de texte
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _fields[index]['value'] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Entrez votre ${_fields[index]['type']}',  // Label au lieu de hintText
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),  // Arrondir les bordures des champs de texte
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],  // Couleur de fond douce
                      ),
                    ),
                  );
                },
              ),
            ),
            // Espace flexible
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _showFieldTypeDialog();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),  // Arrondir les boutons
                ),
                elevation: 5,  // Ajouter un effet d'ombre
              ),
              child: const Text('Ajouter un champ'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String qrData = _getTextForQRCode();
                _showQRCodeDialog(qrData);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text('Générer Code QR'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _showQRCodeDialog(String qrData) {
    final qrCode = QrCode(4, QrErrorCorrectLevel.L);  // génère un objet QR basé sur les données passées.
    qrCode.addData(qrData);
    qrCode.make();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Code QR Généré'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(  // CustomPaint est utilisé pour dessiner le code QR sur l'interface
                  painter: QrPainter(qrCode: qrCode),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFieldTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedType;
        return AlertDialog(
          title: const Text('Choisissez le type de champ'),
          content: DropdownButton<String>(
            isExpanded: true,
            value: selectedType,
            items: _fieldTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            hint: const Text('Sélectionnez un type de champ'),
            onChanged: (String? newValue) {
              setState(() {
                selectedType = newValue;
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (selectedType != null) {
                  _addField(selectedType!);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}

class QrPainter extends CustomPainter {
  final QrCode qrCode;

  QrPainter({required this.qrCode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final moduleSize = size.width / qrCode.moduleCount;

    for (int x = 0; x < qrCode.moduleCount; x++) {
      for (int y = 0; y < qrCode.moduleCount; y++) {
        if (qrCode.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(x * moduleSize, y * moduleSize, moduleSize, moduleSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
