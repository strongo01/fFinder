import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SimpleBarcodeScannerPage extends StatefulWidget {
  const SimpleBarcodeScannerPage({Key? key}) : super(key: key);

  @override
  State<SimpleBarcodeScannerPage> createState() => _SimpleBarcodeScannerPageState();
}

class _SimpleBarcodeScannerPageState extends State<SimpleBarcodeScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: (capture) {
            // In v3+ kan capture meerdere barcodes bevatten
            final List<Barcode> barcodes = capture.barcodes;
            if (!_isScanned && barcodes.isNotEmpty) {
              _isScanned = true;
              final String? code = barcodes.first.rawValue;
              if (code != null) {
                Navigator.of(context).pop(code);
              }
            }
          },
        ),
        Positioned(
          top: 16,
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
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
