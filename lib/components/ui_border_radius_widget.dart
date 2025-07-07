import 'package:flutter/material.dart';


class UiBorderRadiusWidget extends StatelessWidget {

  final double? width;
  final double? height;
  final Widget child;
  final Color? color;
  final double borderRadius;

  const UiBorderRadiusWidget({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.color = Colors.white,
    this.borderRadius = 8,
  });

  @override
  Widget build(context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }

}