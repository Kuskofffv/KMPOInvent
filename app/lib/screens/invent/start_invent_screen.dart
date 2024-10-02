import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/screens/invent/select_objects_invent_screen.dart';
import 'package:brigantina_invent/utils/parse_util.dart';
import 'package:brigantina_invent/widget/loader_widget.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InventStartScreen extends StatefulWidget {
  const InventStartScreen({Key? key}) : super(key: key);

  @override
  _InventStartScreenState createState() => _InventStartScreenState();
}

class _InventStartScreenState extends State<InventStartScreen> {
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
            'Инвентаризация',
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
                          "Кто будет проводить инвентаризацию?",
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
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                    onPressed: () {
                      if (_checked.isEmpty) {
                        return;
                      }
                      SRRouter.pushReplacement(
                          context, SelectObjectsInventScreen(names: _checked));
                    },
                    child: const Text("Выбрать объекты")),
              )
            ],
          );
        }));
  }
}
