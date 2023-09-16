import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class CloseSlidableOnTap extends StatelessWidget {
  CloseSlidableOnTap({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  final Widget child;
  final SlidableController? controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => controller?.close(),
      child: child,
    );
  }
}
