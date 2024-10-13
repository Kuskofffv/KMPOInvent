// ignore_for_file: deprecated_member_use

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:kmpo_invent/screens/about_app.dart';
import 'package:kmpo_invent/screens/dictionary/places_screen.dart';
import 'package:kmpo_invent/screens/import/import_screen.dart';
import 'package:kmpo_invent/screens/objects/add_object_screen.dart';
import 'package:kmpo_invent/screens/objects/all_objects_screen.dart';
import 'package:kmpo_invent/screens/scan/scan_main_screen.dart';
import 'package:kmpo_invent/services/auth.dart';
import 'package:kmpo_invent/utils/util.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/user.dart';
import 'archive/invent_list_screen.dart';
import 'invent/start_invent_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyStateHomePage();
}

class _MyStateHomePage extends State<MyHomePage> {
  MyUser? user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<MyUser?>(context);
    const divider = SizedBox(
      height: 10,
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'KMPOInvent',
          ),
          actions: <Widget>[
            ElevatedButton.icon(
              onPressed: () async {
                await SRRouter.push(context, AboutPage());
              },
              icon: const Icon(
                Icons.contact_support,
                color: Colors.white,
              ),
              label: const SizedBox.shrink(),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _flatButton("Начать инвентаризацию",
                      screen: const InventStartScreen()),
                  divider,
                  _flatButton(
                    "Сканируйте QR-код",
                    onPressed: () async {
                      final result = await BarcodeScanner.scan(
                        options: const ScanOptions(
                          strings: {
                            'cancel': 'Отмена',
                            'flash_on': 'Включить фонарик',
                            'flash_off': 'Выключить фонарик',
                          },
                        ),
                      );

                      if (result.rawContent.isNotEmpty) {
                        await SRRouter.push(
                            context,
                            ScanMainScreen(
                              qrData: result.rawContent,
                            ));
                      }
                    },
                  ),
                  divider,
                  _flatButton("Объекты", screen: const AllObjectsScreen()),
                  divider,
                  _flatButton("Добавить объект",
                      screen: const AddObjectScreen()),
                  divider,
                  _flatButton("Загрузка данных", screen: const ImportScreen()),
                  divider,
                  _flatButton("Архив", screen: const InventListScreen()),
                  divider,
                  _flatButton("Местоположения", screen: const PlacesScreen()),
                  divider,
                  _flatButton(
                    "Выйти из аккаунта",
                    color: Colors.black54,
                    onPressed: () {
                      AppUtil.areYouSure(
                        context,
                        title: 'Выход',
                        message: 'Вы уверены, что хотите выйти из аккаунта?',
                        button: 'Выйти',
                        onPerform: () async {
                          await AuthService().logOut();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _flatButton(String text,
      {Widget? screen, VoidCallback? onPressed, Color? color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      onPressed: onPressed ??
          () {
            if (screen != null) {
              SRRouter.push(context, screen);
            }
          },
      child: Text(
        text,
      ),
    );
  }

  TextEditingController namesField = TextEditingController();
}
