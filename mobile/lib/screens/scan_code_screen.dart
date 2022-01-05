import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/message_model.dart';
import 'package:flutter_chat_ui/models/user_model.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'chat_settings.dart';

class ScanCodeScreen extends StatefulWidget {
  ScanCodeScreen();

  @override
  _ScanCodeScreenState createState() => _ScanCodeScreenState();
}

class _ScanCodeScreenState extends State<ScanCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Scan Chat Code",
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
      ),
      body: QRView(
        key: qrKey,
        overlay: QrScannerOverlayShape(
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
          borderColor: Colors.green,
          borderRadius: 10.0,
          borderLength: 20.0,
          borderWidth: 10.0,
        ),
        onQRViewCreated: (QRViewController controller) {
          print("QR View created");
          controller.scannedDataStream.listen((scanData) {
            //triggered when QR-code is detected
            print(scanData);
            controller.stopCamera();
            controller.dispose();
            Navigator.pop(context);
          });
        },
      ),
    );
  }
}
