import 'package:core/util/theme/theme_util.dart';
import 'package:kmpo_invent/utils/date.dart';
import 'package:core/core_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ScanInfoScreen extends StatefulWidget {
  final ParseObject data;

  const ScanInfoScreen({required this.data});

  @override
  State<ScanInfoScreen> createState() => _ScanInfoScreenState();
}

class _ScanInfoScreenState extends State<ScanInfoScreen> {
  Widget _buildRow(String title, String? data, Icon icon) {
    return Column(children: <Widget>[
      Text(title),
      const SizedBox(
        height: 20,
      ),
      Container(
        padding: const EdgeInsets.all(10),
        color: ThemeUtil.black80.withOpacity(0.1),
        child: Row(
          children: [
            icon,
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                data ?? "-",
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Данные объекта"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(children: <Widget>[
                  _buildRow(
                      'Инвентарный номер',
                      widget.data.get<String>('number'),
                      const Icon(Icons.qr_code)),
                  _buildRow('Название объекта', widget.data.get<String>('name'),
                      const Icon(Icons.table_restaurant)),
                  _buildRow(
                      'Количество',
                      widget.data.get<int>('count')?.toString(),
                      const Icon(Icons.numbers)),
                  _buildRow(
                      'Местонахождение',
                      widget.data.get<String>('location'),
                      const Icon(Icons.map)),
                  _buildRow(
                      'Материально ответственный',
                      widget.data.get<String>('custodian'),
                      const Icon(Icons.person)),
                  _buildRow(
                      'Время последнего редактирования',
                      DateFormatUtil.strFromDate(widget.data.updatedAt,
                          formatter: "dd-MM-yyyy HH:mm"),
                      const Icon(Icons.timer)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScanInfoDynamicScreen extends StatefulWidget {
  final DynamicModel data;

  const ScanInfoDynamicScreen({required this.data});

  @override
  State<ScanInfoDynamicScreen> createState() => _ScanInfoDynamicScreenState();
}

class _ScanInfoDynamicScreenState extends State<ScanInfoDynamicScreen> {
  Widget _buildRow(String title, String? data, Icon icon) {
    return Column(children: <Widget>[
      Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontFamily: 'Oswald',
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Container(
        padding: const EdgeInsets.all(10),
        color: ThemeUtil.black80.withOpacity(0.1),
        child: Row(
          children: [
            icon,
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                data ?? "-",
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Данные объекта"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(children: <Widget>[
                  _buildRow(
                      'Инвентарный номер',
                      widget.data.stringOpt('number'),
                      const Icon(Icons.qr_code)),
                  _buildRow('Название объекта', widget.data.stringOpt('name'),
                      const Icon(Icons.table_restaurant)),
                  _buildRow(
                      'Количество',
                      widget.data.intOpt('count')?.toString(),
                      const Icon(Icons.numbers)),
                  _buildRow('Местонахождение',
                      widget.data.stringOpt('location'), const Icon(Icons.map)),
                  _buildRow(
                      'Материально ответственный',
                      widget.data.stringOpt('custodian'),
                      const Icon(Icons.person)),
                  _buildRow(
                      'Время последнего редактирования',
                      DateFormatUtil.strFromDate(
                          DateFormatUtil.dateFromStr(
                              widget.data.stringOpt("updatedAt")),
                          formatter: "dd-MM-yyyy HH:mm"),
                      const Icon(Icons.timer)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
