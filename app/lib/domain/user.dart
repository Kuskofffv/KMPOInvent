import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class MyUser {
  late String id;
  late String email;
  late String name;
  late String department;
  late ParseUser parseUser;

  MyUser.fromParseUser(ParseUser user) {
    id = user.objectId ?? "";
    email = user.emailAddress ?? "";
    name = user.get('name') ?? "";
    department = user.get('organization') ?? "";
    parseUser = user;
  }
}
