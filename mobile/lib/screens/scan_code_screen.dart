import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/message_model.dart';
import 'package:flutter_chat_ui/models/user_model.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
          "New Chat",
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          print("QR View created");
          controller.scannedDataStream.listen((scanData) {
            print(scanData);
          });
        },
      ),
    );
  }
}
