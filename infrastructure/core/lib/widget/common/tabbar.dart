import 'package:flutter/material.dart';

class TTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabNames;
  final double leftOffset;

  const TTabBar({
    required this.controller,
    required this.tabNames,
    super.key,
    this.leftOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(leftOffset, 0),
      child: TabBar(
          isScrollable: true,
          controller: controller,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: tabNames
              .map((e) => Tab(
                    text: e,
                    height: 34,
                  ))
              .toList()),
    );
  }
}
