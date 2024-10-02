import 'dart:io';
import 'dart:ui';
import 'package:brigantina_invent/domain/object.dart';
import 'package:brigantina_invent/utils/util.dart';
import 'package:core/util/globals.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class InspectImportedObjectsScreen extends StatefulWidget {
  final List<ObjectData> objects;

  const InspectImportedObjectsScreen({required this.objects});

  @override
  State<InspectImportedObjectsScreen> createState() =>
      _InspectImportedObjectsScreenState();
}

class _InspectImportedObjectsScreenState
    extends State<InspectImportedObjectsScreen> {
  final qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'QR-Code',
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                SRRouter.pop(context);
              },
              icon: const Icon(Icons.close)),
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
                            'KMPOInvent',
                            style: TextStyle(
                                fontFamily: 'Oswald',
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                          QrImageView(
                            //место где будет показан QR код
                            data: widget.objects.last.id,
                            size: 300,
                          ),
                          Text(
                            widget.objects.last.id,
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
                  Text("Количество: ${widget.objects.last.count}",
                      textAlign: TextAlign.center),
                  const SizedBox(
                    height: 20,
                  ),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          // color: Colors.green,
                          // padding: const EdgeInsets.all(20.0),
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
                                //mimeTypes: ["image/png"],
                                text: "Лови QR-код",
                              );
                            } catch (e, s) {
                              if (kDebugMode) {
                                print(e.toString());
                                logger.e(e, error: e, stackTrace: s);
                              }
                            }
                          },
                          child: const Text(
                            "Сохранить QR-Code",
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          // padding: const EdgeInsets.all(15.0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () async {
                            if (widget.objects.isNotEmpty) {
                              widget.objects.removeLast();
                              setState(() {});
                            } else {
                              AppUtil.toast("Все данные добавлены");
                              SRRouter.pop(context);
                            }
                          },
                          child: const Text(
                            'Далее',
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
