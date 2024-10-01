import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MakeAttendanceScreen extends StatefulWidget {
  final String userId; // Add this line

  const MakeAttendanceScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _MakeAttendanceScreenState createState() => _MakeAttendanceScreenState();
}

class _MakeAttendanceScreenState extends State<MakeAttendanceScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Make Attendance',
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: (controller) {
                  this.controller = controller;
                  controller.scannedDataStream.listen((scanData) {
                    setState(() {
                      result = scanData;
                    });
                  });
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  result != null
                      ? 'Scanned QR Code: ${result!.code}'
                      : 'Scan a QR code',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 79, 255, 85), // Green color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15), // Rounded corner radius
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  if (result != null) {
                    final formattedDate =
                        DateFormat('yyyy-MM-dd').format(DateTime.now());

                    // Check if the document exists
                    DocumentSnapshot documentSnapshot = await FirebaseFirestore
                        .instance
                        .collection('attendance')
                        .doc(formattedDate)
                        .get();

                    // If the document doesn't exist, create it with the new field
                    if (!documentSnapshot.exists) {
                      await FirebaseFirestore.instance
                          .collection('attendance')
                          .doc(formattedDate)
                          .set({
                        'userId' + widget.userId: widget.userId,
                      });
                    } else {
                      // If the document exists, update the field
                      await FirebaseFirestore.instance
                          .collection('attendance')
                          .doc(formattedDate)
                          .update({
                        'userId' + widget.userId: widget.userId,
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Attendance saved')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No QR code scanned')));
                  }
                },
                child: Text('Save Attendance'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
