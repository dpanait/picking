import 'package:flutter/material.dart';

class SwipeDetector extends StatelessWidget {
  final Widget child;
  final Function onSwipeLeft;
  final Function onSwipeRight;

  SwipeDetector({required this.child, required this.onSwipeLeft, required this.onSwipeRight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 0) {
          // Deslizamiento hacia la derecha
          // if (onSwipeRight != null) {
          //   onSwipeRight();
          // }
          onSwipeLeft();
        } else {
          // Deslizamiento hacia la izquierda
          // if (onSwipeLeft != null) {
          //   onSwipeLeft();
          // }
          onSwipeRight();
        }
      },
      child: child,
    );
  }
}
