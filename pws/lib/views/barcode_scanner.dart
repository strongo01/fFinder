import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SimpleBarcodeScannerPage extends StatefulWidget {
  const SimpleBarcodeScannerPage({Key? key}) : super(key: key); // eenvoudige barcode scanner pagina

  @override
  State<SimpleBarcodeScannerPage> createState() => _SimpleBarcodeScannerPageState();
}

class _SimpleBarcodeScannerPageState extends State<SimpleBarcodeScannerPage> {
  final MobileScannerController cameraController = MobileScannerController(); // controller voor de mobiele scanner
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController, // mobiele scanner widget
            onDetect: (capture) { // wanneer een barcode wordt gedetecteerd
              final List<Barcode> barcodes = capture.barcodes; // lijst van gedetecteerde barcodes
              if (!_isScanned && barcodes.isNotEmpty) {
                _isScanned = true;
                final String? code = barcodes.first.rawValue; // haalt de waarde van de eerste barcode op
                if (code != null) { // als er een geldige code is
                  Navigator.of(context).pop(code);
                }
              }
            },
          ),
          Positioned(
            top: 60,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            top: 60,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.flash_on),
              color: Colors.white,
              onPressed: () {
                cameraController.toggleTorch();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose(); // maakt de controller schoon bij het verwijderen van de widget
    super.dispose();
  }
}