import 'package:core/core_dependencies.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:kmpo_invent/screens/objects/select_mol_print_screen.dart';
import 'package:kmpo_invent/screens/scan/scan_main_screen.dart';
import 'package:kmpo_invent/utils/parse_util.dart';
import 'package:kmpo_invent/widget/loader_widget.dart';

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
          ),
          actions: [
            IconButton(
                onPressed: () {
                  SRRouter.push(context, const SelectMolPrintScreen());
                },
                icon: const Icon(Icons.print_outlined))
          ],
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
                    hintText: "Поиск",
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  ),
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
