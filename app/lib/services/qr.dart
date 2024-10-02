import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:brigantina_invent/utils/worker_manager/worker_manager.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class QrUtil {
  QrUtil._();

  static Future share(List<String> list, QrCardSize size) async {
    if (list.isEmpty) {
      return;
    }

    await WorkerManager.smartAsyncOperation((controller) async {
      await SRRouter.operationWithToast(operation: () async {
        await _share(list, size, controller);
        return 0;
      });
    });
  }

  static Future _share(
      List<String> list, QrCardSize size, OperationContoller controller) async {
    final pdf = pw.Document();
    final xSize = size.dx;
    final ySize = size.dy;
    final width = PdfPageFormat.a4.availableWidth;
    final height = PdfPageFormat.a4.availableHeight;
    final cardWidth = width / xSize - 1;
    final cardHeight = height / ySize - 1;

    final qrSize = cardWidth * 0.7;
    final textHeight = (cardHeight - qrSize) / 2;
    final textSize = textHeight / 2;

    for (int page = 0; page < (list.length / size.cardsCount).ceil(); page++) {
      final qrDataList = List<String?>.generate(size.cardsCount,
          (index) => list.getOrNull(page * size.cardsCount + index));

      final List<pw.Widget> qrWidgets = [];

      for (final qrData in qrDataList) {
        if (qrData == null) {
          qrWidgets.add(pw.Container(
            width: cardWidth,
            height: cardHeight,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.black,
                width: 1,
              ),
            ),
          ));
          continue;
        }

        final qr = pw.Barcode.qrCode().toSvg(
          qrData,
          width: qrSize,
          height: qrSize,
        );

        final imageBytes = await _textToImageBytes(qrData, 32, Colors.black);
        final imageWidget =
            pw.Image(pw.MemoryImage(imageBytes), height: textSize * 1.2);
        await controller.checkMaybeWait();

        qrWidgets.add(pw.Container(
          width: cardWidth,
          height: cardHeight,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            ),
          ),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.SizedBox(
                  height: textHeight,
                  child: pw.Center(
                    child: pw.Text('KMPOInvent',
                        style: pw.TextStyle(fontSize: textSize)),
                  ),
                ),
                pw.SizedBox(
                  height: qrSize,
                  child: pw.FittedBox(
                    fit: pw.BoxFit.contain,
                    child: pw.SvgImage(svg: qr),
                  ),
                ),
                pw.SizedBox(
                    height: textHeight,
                    child: pw.Center(
                      child: imageWidget,
                    )),
              ]),
        ));
      }

      final content = pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            for (var y = 0; y < ySize; y++)
              pw.SizedBox(
                height: cardHeight,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    for (var x = 0; x < xSize; x++) qrWidgets[y * xSize + x],
                  ],
                ),
              ),
          ]);

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return content;
          }));

      await controller.checkMaybeWait();
    }

    final appDir = await getApplicationDocumentsDirectory();
    //current time
    final datetime = DateTime.now();
    //qr image file creation
    final file = await File('${appDir.path}/$datetime.pdf').create();
    await file.writeAsBytes(await pdf.save());

    await controller.checkMaybeWait();

    unawaited(Share.shareXFiles(
      [XFile(file.path, mimeType: "application/pdf")],
      text: list.length == 1 ? "Лови QR-код" : "Лови QR-коды",
    ));
  }
}

enum QrCardSize {
  small._(4, 5),
  medium._(3, 4),
  large._(2, 3);

  final int dx;
  final int dy;
  int get cardsCount => dx * dy;

  String get title => "$dx x $dy";

  const QrCardSize._(this.dx, this.dy);
}

Future<Uint8List> _textToImageBytes(
    String text, double fontSize, Color textColor) async {
  // Создаем TextPainter для рендеринга текста
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  // Создаем PictureRecorder для записи изображения
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  // Рисуем текст
  textPainter.paint(canvas, const Offset(0, 0));

  // Преобразуем Picture в Image
  final ui.Image image = await pictureRecorder
      .endRecording()
      .toImage(textPainter.width.toInt(), textPainter.height.toInt());

  // Преобразуем Image в байты
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
