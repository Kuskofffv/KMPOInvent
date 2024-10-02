import 'package:core/util/routing/page_route.dart';
import 'package:flutter/material.dart';

class Screen404 extends StatelessWidget with TPageRouteScreen {
  final String? url;

  const Screen404({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text(
          '404',
          style: TextStyle(
              fontSize: 60, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  String inAppUrl() {
    return url ?? "/404";
  }
}
