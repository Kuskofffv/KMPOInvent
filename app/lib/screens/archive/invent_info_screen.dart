import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kmpo_invent/domain/user.dart';
import 'package:kmpo_invent/screens/invent/end_invent_screen.dart';
import 'package:kmpo_invent/utils/date.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

class InventInfoScreen extends StatefulWidget {
  final Map<String, dynamic> listObj;
  final String? timeEnd;
  final String? names;
  final String? id;
  final ParseObject parseObject;

  const InventInfoScreen(
      {required this.listObj,
      required this.parseObject,
      this.id,
      this.timeEnd,
      this.names});

  @override
  State<InventInfoScreen> createState() => _InventInfoScreenState();
}

class _InventInfoScreenState extends State<InventInfoScreen> {
  MyUser? user;

  Map<String, dynamic> get listObj => widget.listObj;
  String? get time => widget.timeEnd;

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
        title: const Text('Результат'),
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
              Text(
                'Инвентаризация пройдена: ${DateFormatUtil.strFromDate(widget.parseObject.createdAt, formatter: "dd.MM.yyyy HH:mm")}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.listObj.isNotEmpty)
                Text(
                  'Участие в инвентаризации принимали: ${widget.names}.\nК сожалению, по завершению работы была выявлена недосдача. Было недосчитано ${listObj.length} ${Intl.plural(listObj.length, one: "объект", few: "объекта", other: "объектов")}.\nВот их инвентарные номера ($remainNumbers).',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                    'Участие в инвентаризации принимали: ${widget.names}.\nРезультат получился успешный.',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final xls.Workbook workbook = xls.Workbook();
                  await Excel.createExcel(
                      user!, workbook, widget.id!, widget.parseObject);
                },
                child: const Text(
                  'Открыть таблицу',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
