import 'package:flutter/material.dart';

class THBrandIcon extends StatelessWidget {
  const THBrandIcon({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2D42),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'T.H',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
