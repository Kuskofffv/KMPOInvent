import 'package:brigantina_invent/screens/scan/scan_main_screen.dart';
import 'package:brigantina_invent/utils/parse_util.dart';
import 'package:brigantina_invent/widget/loader_widget.dart';
import 'package:core/core_dependencies.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';

class AllObjectsScreen extends StatefulWidget {
  const AllObjectsScreen({Key? key}) : super(key: key);

  @override
  _AllObjectsScreenState createState() => _AllObjectsScreenState();
}

class _AllObjectsScreenState extends State<AllObjectsScreen> {
  final _textController = TextEditingController();
  List<DynamicModel> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Объекты',
            style: TextStyle(
              fontSize: 21,
              fontFamily: 'Oswald',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: LoaderWidget(operation: () async {
          final data = await parseFunc("objects");
          return data.dynamicListOpt("items") ?? <DynamicModel>[];
        }, onResult: (items) {
          _items = items;
        }, builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                      hintText: "Поиск", prefixIcon: Icon(Icons.search)),
                  controller: _textController,
                  onChanged: (value) {
                    setState(() {
                      _items = snapshot.data
                          .where((element) =>
                              element
                                  .stringOpt("name")!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              element
                                  .stringOpt("number")!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            onTap: () {
                              SRRouter.push(
                                  context,
                                  ScanMainScreen(
                                      qrData: item.stringOpt("number") ?? ""));
                            },
                            title: Text(
                                "${item.stringOpt('number') ?? ""}\n${item.stringOpt('name') ?? ""}"),
                          );
                        }),
                  ],
                ),
              )
            ],
          );
        }));
  }
}
