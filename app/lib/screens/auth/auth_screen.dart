import 'dart:async';

import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/screens/auth/reset_password_screen.dart';
import 'package:brigantina_invent/services/auth.dart';
import 'package:core/util/globals.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage({Key? key}) : super(key: key);

  @override
  _AuthorizationState createState() => _AuthorizationState();
}

class _AuthorizationState extends State<AuthorizationPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController();

  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    Widget _logo() {
      return const Padding(
          padding: EdgeInsets.only(top: 30, bottom: 20),
          child: Align(
              child: Text(
            'KMPOInvent',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Oswald',
            ),
          )));
    }

    Widget _input(Icon icon, String hint, TextEditingController controller,
        bool obscure) {
      return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 20),
          decoration: InputDecoration(
            hintStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black26),
            hintText: hint,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 3),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45, width: 1),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: IconTheme(
                data: const IconThemeData(color: Colors.black),
                child: icon,
              ),
            ),
          ),
        ),
      );
    }

    Widget _button(String text, void Function() func) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: func,
        child: Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
      );
    }

    Widget _form(String label, void Function() func) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ignore: prefer_if_elements_to_conditional_expressions
          (!showLogin
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _input(
                      const Icon(Icons.person), "ФИО", _nameController, false),
                )
              : emptyWidget),
          // ignore: prefer_if_elements_to_conditional_expressions
          (!showLogin
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _input(const Icon(Icons.person), "Отдел",
                      _departmentController, false),
                )
              : emptyWidget),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _input(const Icon(Icons.email), "Электронная почта",
                _emailController, false),
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _input(
                  const Icon(Icons.lock), "Пароль", _passwordController, true)),
          // ignore: prefer_if_elements_to_conditional_expressions
          (showLogin
              ? (Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: GestureDetector(
                    child: const Text(
                      "Забыл пароль?",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onTap: () async {
                      final email = await SRRouter.push<String>(
                          context, const ResetPasswordScreen());
                      if (email != null) {
                        _emailController.text = email;
                      }
                    },
                  ),
                ))
              : const Text('')),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: _button(label, func),
          )
        ],
      );
    }

    Future<void> _loginButtonAction() async {
      final String _email = _emailController.text;
      final String _password = _passwordController.text;

      if (_email.isEmpty || _password.isEmpty) {
        return;
      }

      final MyUser? user =
          await Provider.of<AuthService>(context, listen: false)
              .signInWithEmailAndPassword(_email.trim(), _password.trim());
      if (user == null) {
        unawaited(Fluttertoast.showToast(
            msg: "Неправильно ввели почту или пароль",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16));
      }
    }

    Future<void> _registerButtonAction() async {
      final String fio = _nameController.text.trim();
      final String department = _departmentController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final RegExp regExpMail = RegExp(
          "[a-zA-Z0-9+._%-+]{1,256}@[a-zA-Z0-9][a-zA-Z0-9-]{0,64}(.[a-zA-Z0-9][a-zA-Z0-9-]{0,25})+");
      final RegExp regExpPass = RegExp(r'^.{6,}$');

      if (fio.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          department.isEmpty) {
        return;
      }

      if (!regExpMail.hasMatch(email)) {
        unawaited(Fluttertoast.showToast(
            msg: "Неверная почта",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16));
        return;
      }

      if (!regExpPass.hasMatch(password)) {
        unawaited(Fluttertoast.showToast(
            msg: "Слишком короткий пароль",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16));
        return;
      }

      final MyUser? user =
          await Provider.of<AuthService>(context, listen: false)
              .registerWithEmailAndPassword(fio, department, email, password);

      if (user == null) {
        unawaited(Fluttertoast.showToast(
            msg: "Неправильно ввели почту или пароль",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16));
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 60,
                ),
                Image.asset(
                  'assets/images/icona.png',
                  fit: BoxFit.fitHeight,
                  height: 120,
                ),
                _logo(),
                // ignore: prefer_if_elements_to_conditional_expressions
                (showLogin
                    ? Column(
                        children: <Widget>[
                          _form('Войти', _loginButtonAction),
                          InkWell(
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Ещё не зарегистрированы?\nПройдите регистрацию!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                showLogin = false;
                              });
                            },
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          _form('Регистрация', _registerButtonAction),
                          InkWell(
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Уже зарегистрированны?\nВойдите",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                showLogin = true;
                              });
                            },
                          ),
                        ],
                      )),
              ],
            ),
          ),
        ));
  }
}
