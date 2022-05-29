import 'package:flutter/material.dart';

class Ball extends StatelessWidget {
  late final x;
  late final y;
  late final ballSize;
  Ball(this.x, this.y, this.ballSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
        width: MediaQuery.of(context).size.width * ballSize / 2,
        height: MediaQuery.of(context).size.height * ballSize / 2,
      ),
    );
  }
}