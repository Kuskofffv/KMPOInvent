import 'dart:async';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/utils/date.dart';
import 'package:brigantina_invent/utils/util.dart';
import 'package:brigantina_invent/widget/loader_widget.dart';
import 'package:core/core_dependencies.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';

import 'end_invent_screen.dart';

class InventScreen extends StatefulWidget {
  final List<String> names;
  final List<DynamicModel> objects;

  const InventScreen({required this.names, required this.objects, Key? key})
      : super(key: key);

  @override
  _InventScreenState createState() => _InventScreenState();
}

class _InventScreenState extends State<InventScreen> {
  int count = 0;
  Map<String, dynamic> objectCounts = {};
  Map<String, Color?> objectColors = {};
  List<dynamic> objects = [];
  late final DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context, listen: false)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Инвентаризация',
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                AppUtil.areYouSure(context,
                    title: "Выйход",
                    message:
                        "Вы уверены, что хотите из процесса инвентаризации? Все данные текущей инвентаризации будут потеряны.",
                    button: "Выйти", onPerform: () {
                  SRRouter.popUntilTop(context);
                });
              },
              icon: const Icon(Icons.close)),
          actions: <Widget>[
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Инвентаризация'),
                      content: const Text(
                          'Вы уверены, что хотите закончить инвентаризацию?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Отмена'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text('Закончить'),
                          onPressed: () async {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (result != true) {
                  return;
                }

                final parseObject =
                    await SRRouter.operationWithToast(operation: () async {
                  final parseObject = ParseObject("Invents")
                    ..set("start_date", DateFormatUtil.strFromDate(_startDate))
                    ..set("user_id", user.id)
                    ..set("user_name", user.name)
                    ..set("names", widget.names.join(", "))
                    ..set("list", objectCounts)
                    ..set("objects", objects);

                  if (!(await parseObject.save()).success) {
                    throw Exception('Ошибка сохранения');
                  }
                  return parseObject;
                });

                if (parseObject == null) {
                  return;
                }

                unawaited(Fluttertoast.showToast(
                    msg: "Инвентаризация завершена",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16));

                await SRRouter.pushReplacement(
                    context,
                    EndInventScreen(
                        countObj: count,
                        listObj: objectCounts,
                        time: DateFormat.yMd()
                            .add_Hm()
                            .format(DateTime.now())
                            .toString(),
                        objects: objects,
                        parseObject: parseObject));
              },
              icon: const Icon(
                Icons.stop_screen_share_outlined,
                color: Colors.white,
              ),
              label: const SizedBox.shrink(),
            ),
          ],
        ),
        body: LoaderWidget(operation: () async {
          return widget.objects;
        }, onResult: (list) {
          for (final item in list) {
            final number = item.stringOpt("number") ?? "";
            if (objectColors[number] == null) {
              objectColors[number] = Colors.black54;
              objects.add(item.toJson());
              objectCounts[number] = 0;
            }
          }
        }, builder: (context, snapshot) {
          final list = snapshot.data;
          return ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];

                final number = item.stringOpt("number") ?? "";
                final name = item.stringOpt("name") ?? "";
                final place = item.stringOpt("place");

                final createdAt =
                    DateFormatUtil.dateFromStr(item.stringOpt("createdAt"));
                final createdAtStr = DateFormatUtil.strFromDate(createdAt,
                    formatter: "dd.MM.yyyy HH:mm");

                return Card(
                  color: objectColors[number],
                  child: ListTile(
                    leading: const Icon(
                      Icons.qr_code_outlined,
                      color: Colors.white,
                    ),
                    trailing: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    title: Text(
                      '$number\n$name\n${place != null ? "\n$place" : ""}\n$createdAtStr',
                      style: const TextStyle(color: Colors.white),
                    ),
                    // subtitle: Text(
                    //   '$place - $name ($createdAtStr)',
                    //   style: const TextStyle(color: Colors.white),
                    // ),
                    onTap: () async {
                      final result = await BarcodeScanner.scan(
                        options: const ScanOptions(
                          strings: {
                            'cancel': 'Отмена',
                            'flash_on': 'Включить фонарик',
                            'flash_off': 'Выключить фонарик',
                          },
                        ),
                      );

                      if (result.rawContent == "") {
                        return;
                      }

                      if (result.rawContent != number) {
                        setState(() {
                          if (!objectCounts.containsKey(number)) {
                            objectCounts[number] = 0;
                          }
                          objectColors[number] = Colors.red;
                        });
                        unawaited(Fluttertoast.showToast(
                            msg: "Вы отсканировали не тот QR-Code",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 3,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16));
                        return;
                      }

                      final TextEditingController countField =
                          TextEditingController(text: "1");

                      final value = await showDialog<int>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Введите количество'),
                            content: Row(
                              children: <Widget>[
                                Expanded(
                                    child: TextField(
                                  controller: countField,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: const InputDecoration(
                                      labelText: 'Кол-во', hintText: '10'),
                                ))
                              ],
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Ок'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(countField.text.toIntOrNull());
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (value == null) {
                        return;
                      }

                      if (value >= count) {
                        setState(() {
                          if (objectCounts.containsKey(number)) {
                            objectCounts.remove(number);
                          }
                          objectColors[number] = Colors.green;
                        });
                      } else {
                        setState(() {
                          objectCounts[number] = value;
                          objectColors[number] = Colors.red;
                        });
                        unawaited(Fluttertoast.showToast(
                            msg:
                                "Разница на ${count - value} ${Intl.plural(count - value, one: "позицию", few: "позиции", other: "позиций")}",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16));
                      }
                    },
                  ),
                );
              });
        }),
      ),
    );
  }
}
