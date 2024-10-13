import 'package:core/util/exception/app_exception.dart';
import 'package:kmpo_invent/utils/util.dart';
import 'package:kmpo_invent/widget/loader_widget.dart';

import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final _loaderController = LoaderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Местоположения',
          style: TextStyle(
              fontFamily: 'Oswald', fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final name = TextEditingController();

              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Добавление местоположения'),
                    content: Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                          controller: name,
                          autofocus: true,
                          decoration: const InputDecoration(
                              labelText: 'Название', hintText: 'Аудитория'),
                        ))
                      ],
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Добавить'),
                        onPressed: () async {
                          final result = await SRRouter.operationWithToast(
                              operation: () async {
                            final mol = ParseObject('Places')
                              ..set('name', name.text);

                            if (!(await mol.save()).success) {
                              throw const AppException('Ошибка сохранения');
                            }
                            return 0;
                          });

                          if (result != null) {
                            SRRouter.pop(context);
                            await _loaderController.loadData();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: LoaderWidget<List<ParseObject>>(
          controller: _loaderController,
          operation: () async {
            final query = QueryBuilder<ParseObject>(ParseObject('Places'))
              ..setLimit(1000);
            final response = await query.query();

            if (!response.success) {
              throw AppException(response.error!.message);
            }

            return List<ParseObject>.from(response.results ?? []);
          },
          builder: (context, snapshot) {
            if (snapshot.data.isEmpty) {
              return const Center(
                child: Text('Нет данных'),
              );
            }

            return ListView.builder(
              itemBuilder: (context, index) {
                final mol = snapshot.data[index];

                return ListTile(
                  title: Text(mol.get<String>('name') ?? ""),
                  trailing: IconButton(
                      onPressed: () {
                        AppUtil.areYouSure(
                          context,
                          title: 'Удаление',
                          message:
                              'Вы уверены, что хотите удалить местоположение?',
                          button: 'Удалить',
                          onPerform: () {
                            SRRouter.operationWithToast(
                              operation: () async {
                                if (!(await mol.delete()).success) {
                                  throw const AppException('Ошибка удаления');
                                }
                                return 0;
                              },
                            ).then((result) {
                              if (result != null) {
                                _loaderController.loadData();
                              }
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.delete)),
                );
              },
              itemCount: snapshot.data.length,
            );
          }),
    );
  }
}
