import 'package:brigantina_invent/utils/parse_util.dart';
import 'package:brigantina_invent/widget/loader_widget.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';

class UserSelectorScreen extends StatefulWidget {
  const UserSelectorScreen({super.key});

  @override
  State<UserSelectorScreen> createState() => _UserSelectorScreenState();
}

class _UserSelectorScreenState extends State<UserSelectorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Выберите пользователя"),
      ),
      body: LoaderWidget(operation: () async {
        return (await parseFunc("usernames")).stringListOpt("items") ??
            <String>[];
      }, builder: (context, snapshot) {
        final users = snapshot.data;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return InkWell(
              onTap: () {
                SRRouter.pop(context, user);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  user,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
