import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:kmpo_invent/domain/user.dart';
import 'package:kmpo_invent/screens/invent/select_mol_invent_screen.dart';
import 'package:kmpo_invent/utils/parse_util.dart';
import 'package:kmpo_invent/widget/loader_widget.dart';
import 'package:provider/provider.dart';

class InventStartScreen extends StatefulWidget {
  final void Function(List<String>, List<String>)? customCallback;
  const InventStartScreen({Key? key, this.customCallback}) : super(key: key);

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
                          "Кто будет проводить инвентаризацию (комиссия)?",
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
                          context,
                          SelectMolInventScreen(
                            names: _checked,
                            customCallback: widget.customCallback,
                          ));
                    },
                    child: const Text("Выбрать")),
              )
            ],
          );
        }));
  }
}
