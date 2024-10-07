import 'dart:async';

import 'package:brigantina_invent/domain/user.dart';
import 'package:brigantina_invent/screens/auth/auth_screen.dart';
import 'package:brigantina_invent/screens/home_page.dart';
import 'package:brigantina_invent/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);

    if (user == null) {
      return const AuthorizationPage();
    } else if (user.parseUser.emailVerified ?? false) {
      return const MyHomePage();
    } else {
      return WaitForEmailValidation(
        user: user.parseUser,
      );
    }
  }
}

class WaitForEmailValidation extends StatefulWidget {
  final ParseUser user;

  const WaitForEmailValidation({required this.user, super.key});

  @override
  State<WaitForEmailValidation> createState() => _WaitForEmailValidationState();
}

class _WaitForEmailValidationState extends State<WaitForEmailValidation> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await Provider.of<AuthService>(context, listen: false).fetchUser();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/icona.png',
              fit: BoxFit.fitHeight,
              height: 120,
            ),
            _logo(),
            const Text(
              'Ждем подтверждения почты',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  widget.user.verificationEmailRequest();
                },
                child: const Text('Отправить еще раз'),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  AuthService().logOut();
                },
                child: const Text('Выйти'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
