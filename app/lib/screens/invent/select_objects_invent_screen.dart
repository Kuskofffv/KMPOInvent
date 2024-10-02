import 'package:brigantina_invent/screens/invent/perform_invent_screen.dart';
import 'package:brigantina_invent/utils/parse_util.dart';
import 'package:brigantina_invent/widget/loader_widget.dart';
import 'package:core/core_dependencies.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';

class SelectObjectsInventScreen extends StatefulWidget {
  final List<String> names;
  final List<String> mols;
  const SelectObjectsInventScreen(
      {required this.names, required this.mols, Key? key})
      : super(key: key);

  @override
  _SelectObjectsInventScreenState createState() =>
      _SelectObjectsInventScreenState();
}

class _SelectObjectsInventScreenState extends State<SelectObjectsInventScreen> {
  final _checked = <DynamicModel>[];
  List<DynamicModel> _items = [];

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                    onPressed: () {
                      if (_checked.isEmpty) {
                        return;
                      }
                      SRRouter.pushReplacement(context,
                          InventScreen(names: widget.names, objects: _checked));
                    },
                    child: const Text("Начать инвентаризацию")),
              )
            ],
          );
        }));
  }
}
