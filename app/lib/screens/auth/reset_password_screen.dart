import 'dart:async';

import 'package:kmpo_invent/domain/user.dart';
import 'package:kmpo_invent/utils/parse_util.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  MyUser? user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<MyUser?>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 60,
              ),
              Image.asset(
                'assets/images/icona.png',
                fit: BoxFit.fitHeight,
                height: 120,
              ),
              const Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    'KMPOInvent',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Oswald',
                    ),
                  )),
              const Text(
                'Введите свою электронную почту для сброса пароля',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _emailController,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black26),
                  hintText: 'Электронная почта',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 3),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 1),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: IconTheme(
                      data: IconThemeData(color: Colors.black),
                      child: Icon(Icons.email),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Отправить',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white),
                  ),
                  onPressed: () async {
                    final result =
                        await SRRouter.operationWithToast(operation: () async {
                      if (_emailController.text.trim().isEmpty) {
                        // ignore: only_throw_errors
                        throw "Введите почту";
                      }
                      await parseFunc("resetPassword", parameters: {
                        "email": _emailController.text.trim(),
                      });
                      return 0;
                    });

                    if (result != null) {
                      unawaited(Fluttertoast.showToast(
                          msg: "Собщение отправлено!!!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16));
                      SRRouter.pop(context, _emailController.text.trim());
                    } else {
                      unawaited(Fluttertoast.showToast(
                          msg: "Попробуйте ввести почту ещё раз",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16));
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final _emailController = TextEditingController();
}
