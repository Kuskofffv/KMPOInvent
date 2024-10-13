import 'package:kmpo_invent/domain/user.dart';
import 'package:kmpo_invent/screens/invent/select_objects_invent_screen.dart';
import 'package:kmpo_invent/utils/parse_util.dart';
import 'package:kmpo_invent/widget/loader_widget.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectMolInventScreen extends StatefulWidget {
  final List<String> names;
  const SelectMolInventScreen({required this.names, Key? key})
      : super(key: key);

  @override
  _SelectMolInventScreenState createState() => _SelectMolInventScreenState();
}

class _SelectMolInventScreenState extends State<SelectMolInventScreen> {
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
                                _checked
                                  ..clear()
                                  ..add(item);
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
                          SelectObjectsInventScreen(
                              names: widget.names, mols: _checked));
                    },
                    child: const Text("Выбрать")),
              )
            ],
          );
        }));
  }
}
