import 'package:flutter/material.dart';

class Brick extends StatelessWidget {
  late final x;
  late final y;
  late final brickWidth;
  late final brickHeight;
  late final isEnemy;
  late final color;
  Brick(this.x, this.y, this.brickWidth, this.brickHeight, this.isEnemy, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment((2* x +brickWidth)/(2-brickWidth), y),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            alignment: Alignment(0, 0),
            color: color,
            height: MediaQuery.of(context).size.height * brickHeight / 2,
            width: MediaQuery.of(context).size.width * brickWidth / 2,
          ),
        )
    );
  }
}