// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



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