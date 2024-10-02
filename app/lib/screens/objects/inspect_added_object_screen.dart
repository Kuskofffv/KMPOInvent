import 'dart:io';
import 'dart:ui';
import 'package:core/util/globals.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class InspectAddedObjectScreen extends StatefulWidget {
  final String qrData;
  final bool hasBackToMainButton;

  const InspectAddedObjectScreen(
      {required this.qrData, required this.hasBackToMainButton});

  @override
  State<InspectAddedObjectScreen> createState() =>
      _InspectAddedObjectScreenState();
}

class _InspectAddedObjectScreenState extends State<InspectAddedObjectScreen> {
  final qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR-Code',
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RepaintBoundary(
                  key: qrKey,
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          'INVENT',
                          style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                        QrImageView(
                          //место где будет показан QR код
                          data: widget.qrData,
                          size: 300,
                        ),
                        Text(
                          widget.qrData,
                          style: const TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 21,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final boundary = qrKey.currentContext!
                              .findRenderObject()! as RenderRepaintBoundary;
                          //captures qr image
                          final image = await boundary.toImage();
                          final byteData = await image.toByteData(
                              format: ImageByteFormat.png);
                          final pngBytes = byteData!.buffer.asUint8List();
                          //app directory for storing images.
                          final appDir =
                              await getApplicationDocumentsDirectory();
                          //current time
                          final datetime = DateTime.now();
                          //qr image file creation
                          final file =
                              await File('${appDir.path}/$datetime.png')
                                  .create();
                          //appending data
                          await file.writeAsBytes(pngBytes);
                          //Shares QR image
                          await Share.shareXFiles(
                            [XFile(file.path, mimeType: "image/png")],
                            text: "Лови QR-код",
                          );
                        } catch (e, s) {
                          logger.e(e.toString(), error: e, stackTrace: s);
                        }
                      },
                      child: const Text(
                        "Сохранить QR-Code",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.hasBackToMainButton)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black54),
                        onPressed: () async {
                          SRRouter.popUntilTop(context);
                        },
                        child: const Text(
                          'Вернуться на главную',
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
