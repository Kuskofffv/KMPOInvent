import 'package:kmpo_invent/services/qr.dart';
import 'package:kmpo_invent/utils/parse_util.dart';
import 'package:kmpo_invent/widget/loader_widget.dart';
import 'package:core/core_dependencies.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:flutter/material.dart';

class SelectObjectsPrintScreen extends StatefulWidget {
  final List<String> mols;
  const SelectObjectsPrintScreen({required this.mols, Key? key})
      : super(key: key);

  @override
  _SelectObjectsPrintScreenState createState() =>
      _SelectObjectsPrintScreenState();
}

class _SelectObjectsPrintScreenState extends State<SelectObjectsPrintScreen> {
  final _checked = <DynamicModel>[];
  List<DynamicModel> _items = [];
  QrCardSize _qrSize = QrCardSize.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Печать',
            style: TextStyle(
              fontSize: 21,
              fontFamily: 'Oswald',
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (_checked.length == _items.length) {
                      _checked.clear();
                    } else {
                      _checked
                        ..clear()
                        ..addAll(_items);
                    }
                  });
                },
                icon: const Icon(Icons.checklist_outlined))
          ],
        ),
        body: LoaderWidget(operation: () async {
          final data = await parseFunc("objects");
          final list = data.dynamicListOpt("items") ?? <DynamicModel>[];
          return list
              .filter((e) => widget.mols.contains(e.stringOpt('custodian')));
        }, onResult: (items) {
          _items = items;
          _checked.addAll(items);
        }, builder: (context, snapshot) {
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
                          "Выберите объекты для инвентаризации",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SliverList.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data[index];
                          return CheckboxListTile(
                              title: Text(
                                  "${item.stringOpt('number') ?? ""}\n${item.stringOpt('name') ?? ""}"),
                              value: _checked.contains(item),
                              onChanged: (value) {
                                setState(() {
                                  if (value!) {
                                    _checked.add(item);
                                  } else {
                                    _checked.remove(item);
                                  }
                                });
                              });
                        }),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      listTileTheme: const ListTileThemeData(
                        horizontalTitleGap: 0,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                            child: Text(
                          "Размер: ",
                          style: TextStyle(fontSize: 16),
                        )),
                        ...QrCardSize.values.map((size) {
                          return Expanded(
                            child: RadioListTile<QrCardSize>(
                                contentPadding: EdgeInsets.zero,
                                value: size,
                                groupValue: _qrSize,
                                title: Text(size.title),
                                onChanged: (value) {
                                  setState(() {
                                    _qrSize = value!;
                                  });
                                }),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: ElevatedButton(
                    onPressed: () async {
                      if (_checked.isEmpty) {
                        return;
                      }

                      await QrUtil.share(
                          _checked
                              .map((e) => e.stringOpt("number") ?? "")
                              .toList(),
                          _qrSize);
                    },
                    child: const Text("Напечатать")),
              )
            ],
          );
        }));
  }
}
