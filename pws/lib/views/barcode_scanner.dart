import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SimpleBarcodeScannerPage extends StatefulWidget {
  const SimpleBarcodeScannerPage({Key? key})
    : super(key: key); // eenvoudige barcode scanner pagina

  @override
  State<SimpleBarcodeScannerPage> createState() =>
      _SimpleBarcodeScannerPageState();
}

class _SimpleBarcodeScannerPageState extends State<SimpleBarcodeScannerPage> {
  final MobileScannerController cameraController =
      MobileScannerController(); // controller voor de mobiele scanner
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController, // mobiele scanner widget
            onDetect: (capture) {
              // wanneer een barcode wordt gedetecteerd
              final List<Barcode> barcodes =
                  capture.barcodes; // lijst van gedetecteerde barcodes
              if (!_isScanned && barcodes.isNotEmpty) {
                _isScanned = true;
                final String? code = barcodes
                    .first
                    .rawValue; // haalt de waarde van de eerste barcode op
                if (code != null) {
                  // als er een geldige code is
                  Navigator.of(context).pop(code);
                }
              }
            },
          ),
          Positioned(
            top: 60,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 48,
                height: 48,
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 16,
            child: GestureDetector(
              onTap: () {
                cameraController.toggleTorch();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 48,
                height: 48,
                child: const Icon(
                  Icons.flash_on,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController
        .dispose(); // maakt de controller schoon bij het verwijderen van de widget
    super.dispose();
  }
}
