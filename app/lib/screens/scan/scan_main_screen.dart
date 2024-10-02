import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/screens/objects/inspect_added_object_screen.dart';
import 'package:brigantina_invent/screens/scan/scan_edit_screen.dart';
import 'package:brigantina_invent/screens/scan/scan_info_screen.dart';
import 'package:brigantina_invent/utils/util.dart';
import 'package:brigantina_invent/widget/loader_widget.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';

class ScanMainScreen extends StatefulWidget {
  final String qrData;
  final ParseObject? payload;

  const ScanMainScreen({required this.qrData, this.payload});

  @override
  State<ScanMainScreen> createState() => _ScanMainScreenState();
}

class _ScanMainScreenState extends State<ScanMainScreen> {
  MyUser? user;
  final _loaderController = LoaderController();

  @override
  Widget build(BuildContext context) {
    user = Provider.of<MyUser?>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Объект")),
      body: LoaderWidget(
          controller: _loaderController,
          operation: () async {
            if (widget.payload != null) {
              return widget.payload!;
            }

            final query = QueryBuilder<ParseObject>(ParseObject('Objects'))
              ..whereEqualTo('number', widget.qrData);

            final data = await query.first();

            if (data != null) {
              return data;
            }

            throw Exception('Объект не найден');
          },
          builder: (context, snapshot) {
            return Center(
                child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    snapshot.data.get<String>('number') ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 21),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    snapshot.data.get<String>('name') ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 21),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: const Text(
                      "QR",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    onPressed: () {
                      SRRouter.push(
                          context,
                          InspectAddedObjectScreen(
                            qrData: snapshot.data.get<String>('number') ?? "",
                            hasBackToMainButton: false,
                          ));
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    child: const Text(
                      "Посмотреть данные",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    onPressed: () {
                      SRRouter.push(
                          context,
                          ScanInfoScreen(
                            data: snapshot.data,
                          ));
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    child: const Text(
                      "Отредактировать данные",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    onPressed: () async {
                      await SRRouter.push(
                          context, ScanEditScreen(data: snapshot.data));
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      child: const Text(
                        "Удалить объект",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: () {
                        AppUtil.areYouSure(context,
                            title: "Удаление",
                            message: "Вы уверены, что хотите удалить объект?",
                            button: "Удалить", onPerform: () async {
                          final result = await SRRouter.operationWithToast(
                              operation: () async {
                            if ((await snapshot.data.delete()).success) {
                              return 0;
                            }
                            // ignore: only_throw_errors
                            throw "Не удалось удалить объект";
                          });

                          if (result != null) {
                            SRRouter.pop(context);
                          }
                        });
                      }),
                ],
              ),
            ));
          }),
    );
  }
}
