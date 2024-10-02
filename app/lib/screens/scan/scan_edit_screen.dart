import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/screens/dictionary/place_selector_screen.dart';
import 'package:brigantina_invent/screens/objects/inspect_added_object_screen.dart';
import 'package:brigantina_invent/utils/date.dart';
import 'package:common/dependencies.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dictionary/user_selector_screen.dart';

class ScanEditScreen extends StatefulWidget {
  final ParseObject? data;

  const ScanEditScreen({required this.data}) : super();

  @override
  _ScanEditStatePage createState() => _ScanEditStatePage();
}

class _ScanEditStatePage extends State<ScanEditScreen> {
  late final _numberField =
      TextEditingController(text: widget.data?.get("number"));
  late final _dateField = TextEditingController(
      text: DateFormatUtil.strFromDate(widget.data?.updatedAt,
          formatter: "dd-MM-yyyy HH:mm"));
  late final _nameField = TextEditingController(text: widget.data?.get("name"));
  late final _custodianField =
      TextEditingController(text: widget.data?.get("custodian"));
  late final _countField = TextEditingController(
      text: widget.data?.get<int>("count")?.toString() ?? "1");
  late final _locationField =
      TextEditingController(text: widget.data?.get("location"));

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context)!;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.data != null ? "Редактирование" : "Добавление",
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text(
                            "Инвентарный номер",
                            style: TextStyle(fontSize: 18),
                          ),
                          TextFormField(
                            enabled: widget.data == null,
                            controller: _numberField,
                            decoration: const InputDecoration(
                              hintText: "M000000145623",
                            ),
                            validator: (value) {
                              if (value.isNullOrEmpty()) {
                                return "Введите номер";
                              }
                              return null;
                            },
                          ),
                          if (widget.data != null) ...[
                            const SizedBox(
                              height: 15,
                            ),
                            const Text(
                              "Дата последнего редактирования",
                              style: TextStyle(fontSize: 18),
                            ),
                            TextField(
                              enabled: false,
                              controller: _dateField,
                            ),
                          ],
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Название объекта",
                            style: TextStyle(fontSize: 18),
                          ),
                          TextFormField(
                            controller: _nameField,
                            decoration: const InputDecoration(
                              hintText: "Компьютерный стол",
                            ),
                            validator: (value) {
                              if (value.isNullOrEmpty()) {
                                return "Введите название";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Материально ответственный",
                            style: TextStyle(fontSize: 18),
                          ),
                          GestureDetector(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              final user = await SRRouter.push<String>(
                                  context, const UserSelectorScreen());
                              if (user != null) {
                                _custodianField.text = user;
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _custodianField,
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Количество",
                            style: TextStyle(fontSize: 18),
                          ),
                          TextFormField(
                            controller: _countField,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              hintText: "155",
                            ),
                            validator: (value) {
                              if (value.isNullOrEmpty()) {
                                return "Введите количество";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Местонахождение",
                            style: TextStyle(fontSize: 18),
                          ),
                          GestureDetector(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              final place = await SRRouter.push<String>(
                                  context, const PlaceSelectorScreen());
                              if (place != null) {
                                _locationField.text = place;
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _locationField,
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text(
                      widget.data != null
                          ? "Обновить объект"
                          : "Добавить объект",
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final result = await SRRouter.operationWithToast(
                          operation: () async {
                        final parseObject =
                            widget.data ?? ParseObject("Objects");

                        if (widget.data == null) {
                          parseObject.set("number", _numberField.text);
                        }

                        parseObject
                          ..set("editor", user.name)
                          ..set("name", _nameField.text)
                          ..set("custodian", _custodianField.text)
                          ..set("count", _countField.text.toIntOrNull() ?? 1)
                          ..set("location", _locationField.text);

                        if (!(await parseObject.save()).success) {
                          throw Exception("Не удалось сохранить объект");
                        }

                        return parseObject;
                      });

                      if (result != null) {
                        if (widget.data == null) {
                          await SRRouter.pushReplacement(
                              context,
                              InspectAddedObjectScreen(
                                qrData: _numberField.text,
                                hasBackToMainButton: true,
                              ));
                        } else {
                          SRRouter.pop(context);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
