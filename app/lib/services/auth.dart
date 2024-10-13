import 'dart:async';

import 'package:kmpo_invent/domain/user.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthService extends ChangeNotifier {
  static final _instance = AuthService._();
  factory AuthService() {
    return _instance;
  }

  AuthService._();

  final StreamController<MyUser?> _userController =
      StreamController<MyUser?>.broadcast();

  Future<MyUser?> signInWithEmailAndPassword(
      String username, String password) async {
    try {
      final user = await ParseUser.currentUser();
      if (user != null) {
        await user.logout();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    try {
      final parseUser = ParseUser(username, password, null);
      final response = await parseUser.login();

      if (response.success) {
        final user = MyUser.fromParseUser(response.result);
        _userController.add(user);
        return user;
      } else {
        if (kDebugMode) {
          print('Login failed');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<MyUser?> registerWithEmailAndPassword(
      String fio, String department, String email, String password) async {
    try {
      final user = await ParseUser.currentUser();
      if (user != null) {
        await user.logout();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    try {
      final parseUser = ParseUser.createUser(email, password, email)
        ..set("organization", department)
        ..set("name", fio);
      final response = await parseUser.signUp();
      if (!response.success) {
        throw Exception(response.error!.message);
      }

      unawaited(parseUser.verificationEmailRequest());

      final user = MyUser.fromParseUser(parseUser);
      _userController.add(user);

      return user;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future logOut() async {
    final parseUser = await ParseUser.currentUser();
    await parseUser?.logout();
    _userController.add(null);
  }

  Stream<MyUser?> get currentUser {
    return _userController.stream;
  }

  Future<void> fetchUser() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      await user.fetch();
      if (user.emailVerified == true) {
        await user.save();
        _userController.add(MyUser.fromParseUser(user));
      }
    } else {
      _userController.add(null);
    }
  }
}
