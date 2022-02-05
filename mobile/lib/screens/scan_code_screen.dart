import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:palk/models/chat.dart';
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
            controller.pauseCamera();
            RegExp exp = RegExp(r"palk:\/\/chat\?id=(.*.)&key=(.*)&name=(.*)");
            var match = exp.matchAsPrefix(scanData.code!);
            if (match != null) {
              var id = match.group(1)!;
              var key = match.group(2)!;
              var name = String.fromCharCodes(base64Decode(match.group(3)!));
              Chat.add(id, key, name).then((value) {
                print("Joined chat '${name}'");
                controller.stopCamera();
                controller.dispose();
                Navigator.pop(context);
              }).catchError((e) {
                controller.resumeCamera();
              });
            } else {
              controller.resumeCamera();
            }
          });
        },
      ),
    );
  }
}
