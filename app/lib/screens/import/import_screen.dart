import 'dart:io';

import 'package:brigantina_invent/domain/object.dart';
import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/utils/parse_util.dart';
import 'package:brigantina_invent/utils/util.dart';
import 'package:brigantina_invent/widget/loader_widget.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/routing/router.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({Key? key}) : super(key: key);

  @override
  _ImportScreenState createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String? _checked;

  @override
  void initState() {
    super.initState();
    _checked = Provider.of<MyUser?>(context, listen: false)!.name;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context)!;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Импорт',
          ),
        ),
        body: LoaderWidget(operation: () {
          return parseFunc("usernames");
        }, builder: (context, snapshot) {
          final items = snapshot.data.stringListOpt("items") ?? [];

          // ignore: cascade_invocations
          items
            ..remove(user.name)
            ..insert(0, user.name);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Выберите материально ответственного.",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SliverList.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return RadioListTile(
                            groupValue: _checked,
                            title: Text(item),
                            value: item,
                            onChanged: (value) {
                              setState(() {
                                _checked = value;
                              });
                            },
                          );
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                    onPressed: () async {
                      if (_checked == null) {
                        return;
                      }

                      final FilePickerResult? result =
                          await FilePicker.platform.pickFiles();

                      if (result == null) {
                        return;
                      }

                      final objects = await SRRouter.operationWithToast(
                          operation: () async {
                        AppUtil.toast("Это займет какое-то время");

                        final PlatformFile file = result.files.first;

                        final fileName = file.path!;
                        final bytes = File(fileName).readAsBytesSync();
                        final excel = Excel.decodeBytes(bytes);
                        final objects = <ObjectData>[];

                        for (final table in excel.tables.keys) {
                          for (final row in excel.tables[table]!.rows) {
                            final rowNotNull =
                                row.mapNotNull((e) => e?.value).toList();
                            final name =
                                cast<SharedString>(rowNotNull.getOrNull(1))
                                    ?.node
                                    // ignore: deprecated_member_use
                                    .text;
                            final id =
                                cast<SharedString>(rowNotNull.getOrNull(2))
                                    ?.node
                                    // ignore: deprecated_member_use
                                    .text;
                            final count = cast<int>(rowNotNull.getOrNull(6));

                            if (name != null && id != null && count != null) {
                              objects.add(ObjectData(
                                  name: name,
                                  id: id,
                                  count: count,
                                  custodian: _checked!));
                            }
                          }
                        }

                        int index = 0;
                        for (final object in objects) {
                          index++;
                          SRRouter.progress((100 * index) ~/ objects.length);
                          final query =
                              QueryBuilder<ParseObject>(ParseObject('Objects'))
                                ..whereEqualTo('number', object.id);
                          final parseObject =
                              (await query.first()) ?? ParseObject('Objects');

                          // ignore: cascade_invocations
                          parseObject
                            ..set("editor", user.name)
                            ..set('name', object.name)
                            ..set('number', object.id)
                            ..set('count', object.count)
                            ..set('custodian', object.custodian);
                          await parseObject.save();
                        }
                        return objects;
                      });

                      if (objects != null) {
                        AppUtil.toast("Импорт завершен");
                        SRRouter.pop(context);
                      } else {
                        AppUtil.toast("Ошибка импорта", isError: true);
                      }
                    },
                    child: const Text("Выбор файла")),
              )
            ],
          );
        }));
  }
}
