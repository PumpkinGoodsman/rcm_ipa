import 'package:flutter/material.dart';

class ReusableText extends StatelessWidget {
  const ReusableText({
    super.key, required this.text, required this.size, required this.fw, this.color,
  });

  final String text;
  final double size;
  final FontWeight fw;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: size,
          color: color ?? Colors.black,
          fontWeight: fw

      ),);
  }
}