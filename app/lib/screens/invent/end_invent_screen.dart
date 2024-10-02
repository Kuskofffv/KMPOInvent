import 'dart:async';
import 'dart:io';

import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/utils/date.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

class EndInventScreen extends StatefulWidget {
  final int? countObj;
  final Map<String, dynamic> listObj;
  final String? time;
  final List<dynamic>? objects;
  final ParseObject parseObject;

  const EndInventScreen({
    required this.listObj,
    required this.parseObject,
    Key? key,
    this.countObj,
    this.time,
    this.objects,
  }) : super(key: key);

  @override
  _EndStatePageInvent createState() => _EndStatePageInvent();
}

class _EndStatePageInvent extends State<EndInventScreen> {
  MyUser? user;
  int? get countObj => widget.countObj;
  Map<String, dynamic> get listObj => widget.listObj;
  String? get time => widget.time;
  List<dynamic>? get objects => widget.objects;

  _EndStatePageInvent();

  @override
  Widget build(BuildContext context) {
    user = Provider.of<MyUser?>(context);

    String? remainNumbers;
    if (listObj.isNotEmpty) {
      if (listObj.length > 5) {
        remainNumbers =
            "${listObj.keys.take(5).join(', ')} и еще ${listObj.length - 5} объектов";
      } else {
        remainNumbers = listObj.keys.join(', ');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Инвентаризация',
          style: TextStyle(
            fontSize: 21,
            fontFamily: 'Oswald',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Инвентаризация завершена!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
              ),
              const SizedBox(
                height: 20,
              ),
              // ignore: prefer_if_elements_to_conditional_expressions
              if (remainNumbers != null)
                Text(
                  'К сожалению, в процессе проведения инвентаризации у вас выявилась недосдача. \nИз ${(countObj!).round()} инвентарных преметов, было недосчитано ${listObj.length} ${Intl.plural(listObj.length, one: "объект", few: "объекта", other: "объектов")}.\nВот их инвентарные номера ($remainNumbers)',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                )
              else
                const Text(
                    'Все инвентарные объекты были найдены и отсканированны.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
              const SizedBox(
                height: 20,
              ),
              IntrinsicWidth(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          unawaited(Fluttertoast.showToast(
                              msg: "Это может занять несколько секунд",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 5,
                              backgroundColor: Colors.orange,
                              textColor: Colors.white,
                              fontSize: 16));

                          final xls.Workbook workbook = xls.Workbook();

                          await Excel.createExcel(
                              user!, workbook, time!, widget.parseObject);
                        },
                        child: const Text(
                          'Открыть таблицу',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () async {
                          SRRouter.popUntilTop(context);
                        },
                        child: const Text(
                          'Вернуться на главную',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Excel {
  static Future<void> createExcel(MyUser user, xls.Workbook workbook,
      String time, ParseObject parseObject) async {
    final fileName = await SRRouter.operationWithToast(operation: () {
      return _createExcel(user, workbook, time, parseObject);
    });

    if (fileName != null) {
      unawaited(OpenFile.open(fileName));
    }
  }

  static Future<String> _createExcel(MyUser user, xls.Workbook workbook,
      String time, ParseObject parseObject) async {
    final titles = [];
    List<int> bytes;

    final startDateStr = DateFormatUtil.strFromDate(
        DateFormatUtil.dateFromStr(parseObject.get('start_date')),
        formatter: "dd.MM.yyyy HH:mm");
    final endDateStr = DateFormatUtil.strFromDate(
        parseObject.createdAt?.toLocal(),
        formatter: "dd.MM.yyyy HH:mm");

    titles
      ..add(user.department)
      ..add(parseObject.get("names"))
      ..add(startDateStr)
      ..add(endDateStr)
      ..add(parseObject.get('list'))
      ..add(parseObject.get('objects'));

    final xls.Worksheet sheet = workbook.worksheets[0]
      ..showGridlines = false
      ..enableSheetCalculations()
      ..getRangeByName('A1').columnWidth = 6.82
      ..getRangeByName('B1').columnWidth = 13.82
      ..getRangeByName('C1').columnWidth = 11.82
      ..getRangeByName('D1:E1').columnWidth = 10.20
      ..getRangeByName('F1').columnWidth = 10
      ..getRangeByName('F11').rowHeight = 50
      ..getRangeByName('G1').columnWidth = 10.82
      ..getRangeByName('H1').columnWidth = 9.10;

    final xls.Style globalStyle2 = workbook.styles.add('globalStyle2')
      ..fontSize = 14;

    final xls.Style globalStyle1 = workbook.styles.add('globalStyle1')
      ..fontSize = 14
      ..borders.bottom.lineStyle = xls.LineStyle.thin
      ..hAlign = xls.HAlignType.center;

    final xls.Style globalStyle3 = workbook.styles.add('globalStyle3')
      ..fontSize = 12
      ..wrapText = true
      ..borders.all.lineStyle = xls.LineStyle.thin
      ..hAlign = xls.HAlignType.center
      ..vAlign = xls.VAlignType.center;

    final xls.Style titleStyle = workbook.styles.add('titleStyle')
      ..fontSize = 18
      ..bold = true
      ..hAlign = xls.HAlignType.center;

    sheet.getRangeByName('B4').setText('Учреждение:');
    sheet.getRangeByName('B5').setText('Ответственные лица:');
    sheet.getRangeByName('B7').setText('Дата проведение:');

    sheet.getRangeByName('C4').setText(titles[0]);

    final List<String> list = titles[1].split(', ');
    if (list.length > 2) {
      sheet.getRangeByName('D5').setText('${list[0]}, ${list[1]}, ');
      for (int i = 2; i < list.length; i++) {
        sheet
            .getRangeByName('B6')
            .setText(list[i] + (((i + 1) < list.length) ? ', ' : ''));
      }
    } else {
      sheet.getRangeByName('D5').setText(titles[1]);
    }
    sheet.getRangeByName('D7').setText(titles[2] + ' - ' + titles[3]);

    sheet.getRangeByName('A2').setText('Акт инвентаризации');
    sheet.getRangeByName('A11').setText('Номер п/п');
    sheet.getRangeByName('B11').setText('Инвентарный номер');
    sheet.getRangeByName('C11').setText('Название объекта');
    sheet.getRangeByName('D11').setText('Локация');
    sheet.getRangeByName('E11').setText('Количество');
    sheet.getRangeByName('F12').setText('Сотрудник');
    sheet.getRangeByName('G12').setText('Дата');
    sheet.getRangeByName('F11').setText('Последнее редактирование');
    sheet.getRangeByName('H11').setText('Найдено штук');
    sheet.getRangeByName('A13').setText('1a');
    sheet.getRangeByName('B13').setText('1');
    sheet.getRangeByName('C13').setText('2');
    sheet.getRangeByName('D13').setText('3');
    sheet.getRangeByName('E13').setText('4');
    sheet.getRangeByName('F13').setText('5');
    sheet.getRangeByName('G13').setText('6');
    sheet.getRangeByName('H13').setText('7');

    sheet.getRangeByName('A2:H2').merge();
    sheet.getRangeByName('B5:C5').merge();
    sheet.getRangeByName('B7:C7').merge();
    sheet.getRangeByName('C4:G4').merge();
    sheet.getRangeByName('D5:G5').merge();
    sheet.getRangeByName('B6:G6').merge();
    sheet.getRangeByName('D7:G7').merge();
    sheet.getRangeByName('A11:A12').merge();
    sheet.getRangeByName('B11:B12').merge();
    sheet.getRangeByName('C11:C12').merge();
    sheet.getRangeByName('D11:D12').merge();
    sheet.getRangeByName('E11:E12').merge();
    sheet.getRangeByName('F11:G11').merge();
    sheet.getRangeByName('H11:H12').merge();

    sheet.getRangeByName('A2:H2').cellStyle = titleStyle;
    sheet.getRangeByName('C4:G4').cellStyle = globalStyle1;
    sheet.getRangeByName('D5:G5').cellStyle = globalStyle1;
    sheet.getRangeByName('B6:G6').cellStyle = globalStyle1;
    sheet.getRangeByName('D7:G7').cellStyle = globalStyle1;
    sheet.getRangeByName('B4:B5').cellStyle = globalStyle2;
    sheet.getRangeByName('B7').cellStyle = globalStyle2;
    sheet.getRangeByName('A11:H${titles[5].length + 13}').cellStyle =
        globalStyle3;
    sheet.getRangeByName('B6').cellStyle.hAlign = xls.HAlignType.left;

    var countObj = 0;
    for (int i = 0; i < titles[5].length; i++) {
      final num = (i + 14).toString();
      final item = titles[5][i];
      sheet.getRangeByName('A$num').setText((i + 1).toString());
      sheet.getRangeByName('B$num').setText(item['number']);
      sheet.getRangeByName('C$num').setText(item['name']);
      sheet.getRangeByName('D$num').setText(item['location']);
      sheet.getRangeByName('E$num').setText(item['count']?.toString());
      sheet.getRangeByName('F$num').setText(item['custodian']);
      sheet.getRangeByName('G$num').setText(DateFormatUtil.strFromDate(
          DateFormatUtil.dateFromStr(item['updatedAt']),
          formatter: "dd.MM.yyyy\nHH:mm"));

      countObj += int.parse(item['count'].toString());

      if (titles[4].containsKey(item['number'])) {
        sheet
            .getRangeByName('H$num')
            .setText(titles[4][item['number']].toString());
      } else {
        sheet.getRangeByName('H$num').setText(item['count']?.toString());
        countObj -= int.parse(item['count'].toString());
      }
    }

    final last = (14 + titles[5].length).toString();

    sheet.getRangeByName('G$last:H$last').cellStyle = globalStyle3;
    sheet.getRangeByName('G$last').setText('Недостача');
    sheet.getRangeByName('G$last').cellStyle.bold = true;
    sheet.getRangeByName('H$last').setText((countObj).toString());

    final last1 = (14 + titles[5].length + 4).toString();
    sheet.getRangeByName('F$last1').setText('Подпись');
    sheet.getRangeByName('F$last1').cellStyle = globalStyle2;
    sheet.getRangeByName('G$last1:H$last1').merge();
    sheet.getRangeByName('G$last1:H$last1').cellStyle = globalStyle1;
    bytes = workbook.saveAsStream();

    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Output.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    return fileName;
  }
}
