import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/screens/objects/select_objects_print_screen.dart';
import 'package:brigantina_invent/utils/parse_util.dart';
import 'package:brigantina_invent/widget/loader_widget.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectMolPrintScreen extends StatefulWidget {
  const SelectMolPrintScreen({Key? key}) : super(key: key);

  @override
  _SelectMolPrintScreenState createState() => _SelectMolPrintScreenState();
}

class _SelectMolPrintScreenState extends State<SelectMolPrintScreen> {
  final _checked = <String>[];

  @override
  void initState() {
    super.initState();
    _checked.add(Provider.of<MyUser?>(context, listen: false)!.name);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context)!;

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
          backgroundColor: Colors.green,
          centerTitle: true,
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
                          "Выберите материально ответственное лицо (МОЛ)?",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SliverList.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return CheckboxListTile(
                            title: Text(item),
                            value: _checked.contains(item),
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  _checked.add(item);
                                } else {
                                  _checked.remove(item);
                                }
                              });
                            },
                          );
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () async {
                      if (_checked.isEmpty) {
                        return;
                      }

                      await SRRouter.pushReplacement(
                          context, SelectObjectsPrintScreen(mols: _checked));
                    },
                    child: const Text("Выбрать")),
              )
            ],
          );
        }));
  }
}
