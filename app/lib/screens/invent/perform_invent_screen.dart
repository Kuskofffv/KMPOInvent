import 'dart:async';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:core/core_dependencies.dart';
import 'package:core/util/exception/app_exception.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/routing/router.dart';
import 'package:core/util/simple.dart';
import 'package:core/util/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kmpo_invent/domain/user.dart';
import 'package:kmpo_invent/screens/calendar/calendar_util.dart';
import 'package:kmpo_invent/screens/scan/scan_info_screen.dart';
import 'package:kmpo_invent/utils/date.dart';
import 'package:kmpo_invent/utils/util.dart';
import 'package:kmpo_invent/widget/loader_widget.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../domain/const.dart';
import 'end_invent_screen.dart';

class InventScreen extends StatefulWidget {
  final List<String> names;
  final List<DynamicModel> objects;
  final int? calendarEventId;

  const InventScreen(
      {required this.names,
      required this.objects,
      required this.calendarEventId,
      Key? key})
      : super(key: key);

  @override
  _InventScreenState createState() => _InventScreenState();
}

class _InventScreenState extends State<InventScreen> {
  int count = 0;
  Map<String, int> objectCounts = {};
  Map<String, Color?> objectColors = {};
  List<dynamic> objects = [];
  List<DynamicModel> scannedObjects = [];
  late final DateTime _startDate;
  List<DynamicModel>? _items;
  final _controller = AutoScrollController();

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
                    throw const AppException('Ошибка сохранения');
                  }
                  return parseObject;
                });

                if (parseObject == null) {
                  return;
                }

                _saveLastAccountDates();

                toast("Инвентаризация завершена",
                    backgroundColor: Const.red, textColor: Colors.white);

                if (widget.calendarEventId != null) {
                  final events = await CalendarUtil.storage.read() ?? [];
                  // ignore: cascade_invocations
                  events.removeWhere(
                      (e) => e.intOpt("id") == widget.calendarEventId);
                  await CalendarUtil.storage.write(events);
                  await CalendarUtil.scheduleAll();
                }

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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: () async {
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

              final item = _items?.firstWhereOrNull(
                  (e) => e.stringOpt("number") == result.rawContent);

              if (item == null) {
                toast("Объект не найден",
                    backgroundColor: Const.red, textColor: Colors.white);

                return;
              }

              unawaited(_controller.scrollToIndex(_items!.indexOf(item),
                  preferPosition: AutoScrollPosition.begin));

              final TextEditingController countField =
                  TextEditingController(text: "1");

              final value = await showDialog<int>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(result.rawContent),
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
                          onSubmitted: (value) {
                            Navigator.of(context)
                                .pop(countField.text.toIntOrNull());
                          },
                          decoration: const InputDecoration(
                            labelText: 'Кол-во',
                            hintText: '10',
                            contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                          ),
                        ))
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
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

              final count = item.intOpt("count") ?? 0;

              final scanned = (objectCounts[result.rawContent] ?? 0) + value;

              if (scanned >= count) {
                setState(() {
                  if (objectCounts.containsKey(result.rawContent)) {
                    objectCounts.remove(result.rawContent);
                  }
                  objectColors[result.rawContent] = Colors.green;
                  scannedObjects.add(item);
                });
              } else {
                setState(() {
                  objectCounts[result.rawContent] = scanned;
                  objectColors[result.rawContent] = Colors.red;
                  scannedObjects.remove(item);
                });

                toast(
                    "Разница на ${count - scanned} ${Intl.plural(count - value, one: "позицию", few: "позиции", other: "позиций")}",
                    backgroundColor: Const.red,
                    textColor: Colors.white);
              }
            },
            child: const Icon(
              Icons.qr_code_2_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
        body: LoaderWidget(operation: () async {
          return widget.objects;
        }, onResult: (list) {
          _items = list;
          for (final item in list) {
            final number = item.stringOpt("number") ?? "";
            if (objectColors[number] == null) {
              objectColors[number] = ThemeUtil.black80;
              objects.add(item.toJson());
              objectCounts[number] = 0;
            }
          }
        }, builder: (context, snapshot) {
          final list = snapshot.data;
          return ListView.builder(
              controller: _controller,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];

                final number = item.stringOpt("number") ?? "";
                final name = item.stringOpt("name") ?? "";
                final place = item.stringOpt("place");
                final count = item.intOpt("count");

                final createdAt =
                    DateFormatUtil.dateFromStr(item.stringOpt("createdAt"));
                final createdAtStr = DateFormatUtil.strFromDate(createdAt,
                    formatter: "dd.MM.yyyy HH:mm");

                return AutoScrollTag(
                  key: ValueKey(index),
                  controller: _controller,
                  index: index,
                  child: Card(
                    color: objectColors[number],
                    child: ListTile(
                      title: Text(
                        '$number\n$name${place != null ? "\n$place" : ""}\n$createdAtStr\nКол-во: $count${(objectCounts[number] ?? 0) != 0 ? "\n\nПросканированно: ${objectCounts[number]}" : ""}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        await SRRouter.push(
                            context, ScanInfoDynamicScreen(data: item));
                      },
                    ),
                  ),
                );
              });
        }),
      ),
    );
  }

  // ignore: avoid_void_async
  void _saveLastAccountDates() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Objects'))
      ..setLimit(1000);
    final response = await query.query();

    if (!response.success) {
      return;
    }

    final list = List<ParseObject>.from(response.results ?? []);

    final map = <String, ParseObject>{};
    for (final parseObject in list) {
      map[parseObject.objectId!] = parseObject;
    }

    final savingParseObjects = scannedObjects.mapNotNull(
      (e) {
        final id = e.stringOpt("objectId");
        if (id != null) {
          final parseObject = map[id];
          if (parseObject != null) {
            parseObject.set("last_accounting_date",
                DateFormatUtil.strFromDate(DateTime.now()));
            return parseObject;
          }
        }
      },
    );

    await Future.wait(savingParseObjects.map((e) => e.save()));
  }
}
