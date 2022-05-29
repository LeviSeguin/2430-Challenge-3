import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:challenge_3_2430/ball.dart';
import 'package:challenge_3_2430/brick.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  //player variables
  double playerX = -0.2;
  double brickWidth = 0.4;
  double brickHeight = 0.1;
  int playerScore = 0;
  double moveDistance = 0.05;
  Color playerCol = Colors.green;

  //enemy variables
  double enemyX = -0.2;
  int enemyScore = 0;
  Color enemyCol = Colors.red;
  double enemySpeed = 0.005;

  //ball variables
  double ballX = 0;
  double ballY = 0;
  double maxBounceAngle = 75;
  double ballSize = 0.1;
  double ballSpeed = 0.007;
  double ballVX = 0;
  double ballVY = -0.007;

  bool gameStarted = false;
  int maxScore = 1;

  void startGame() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 1), (timer) {
      updateBallDirection();
      moveBall();
      moveEnemy();
      if (didEnemyScore()) {
        enemyScore++;
        timer.cancel();
        //check if enemy won
        if (enemyScore >= maxScore) {
          _showDialog(false);
        } else {
          resetGame();
        }

      }
      if (didPlayerScore()) {
        playerScore++;
        timer.cancel();
        //check if player won
        if (playerScore >= maxScore) {
          _showDialog(true);
        } else {
          resetGame();
        }

      }
    });
  }

  double toRad(double n) {
    return n * (pi / 180);
  }

  void updateBallDirection() {
    //used to calculate the angle of the ball compared to the position
    //of the paddle
    double relativeX;
    double normalRelativeX;
    double bounceAngle;

    setState(() {
      //player brick
      if (ballY >= 0.9 - brickHeight &&
          playerX + brickWidth >= ballX &&
          playerX <= ballX) {
        relativeX = (playerX + (brickWidth / 2)) - ballX;
        normalRelativeX = relativeX / (brickWidth / 2);

        if (normalRelativeX <= 0) {
          //right side of brick
          normalRelativeX = -normalRelativeX;
          bounceAngle = 90 - (maxBounceAngle * normalRelativeX);
        } else {
          //left side of brick
          bounceAngle = 90 + (maxBounceAngle * normalRelativeX);
        }

        ballVX = ballSpeed * cos(toRad(bounceAngle));
        ballVY = -ballSpeed * sin(toRad(bounceAngle));
        ballSpeed += 0.0005;

      //enemy brick
      } else if (ballY <= -0.9 + brickHeight &&
          enemyX + brickWidth >= ballX &&
          enemyX <= ballX) {
        relativeX = (enemyX + (brickWidth / 2)) - ballX;
        normalRelativeX = relativeX / (brickWidth / 2);

        if (normalRelativeX <= 0) {
          //right side of brick
          normalRelativeX = -normalRelativeX;
          bounceAngle = 90 - (maxBounceAngle * normalRelativeX);
        } else {
          //left side of brick
          bounceAngle = 90 + (maxBounceAngle * normalRelativeX);
        }
        ballVX = ballSpeed * cos(toRad(bounceAngle));
        ballVY = ballSpeed * sin(toRad(bounceAngle));
        ballSpeed += 0.00001;
      }

      //horizontal
      if (ballX >= 1) {
        ballVX = -ballVX;
        print(ballX);
      } else if (ballX <= -1) {
        ballVX = -ballVX;
      }
    });
  }

  void moveBall() {
    setState(() {
      ballX += ballVX;
      ballY += ballVY;
    });
  }

  void movePlayer(DragUpdateDetails update) {
    setState(() {
      double n = update.delta.dx / (MediaQuery.of(context).size.width / 2);
      if (playerX + n >= -1 && playerX + brickWidth + n <= 1) {
        playerX += n;
      }

    });
  }

  void moveEnemy() {
    setState(() {
      if (enemyX + (brickWidth / 2) < ballX) {
        if (enemyX +brickWidth + enemySpeed < 1) {
          enemyX += enemySpeed;
        }

      } else if (enemyX + (brickWidth / 2) > ballX) {
        if (enemyX - enemySpeed > -1) {
          enemyX -= enemySpeed;
        }
      }
    });
  }

  void resetGame() {
    setState(() {
      ballX = 0;
      ballY = 0;
      playerX = -0.2;
      enemyX = -0.2;
      ballSpeed = 0.007;
      ballVX = 0;
      ballVY = -0.007;
      if (gameStarted) {
        startGame();
      }

    });
  }

  void resetScore() {
    playerScore = 0;
    enemyScore = 0;
  }

  bool didPlayerScore() {
    if (ballY <= -1) {
      return true;
    }
    return false;
  }

  bool didEnemyScore() {
    if (ballY >= 1) {
      return true;
    }
    return false;
  }

  void _showDialog(bool enemyDied) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: enemyDied ? playerCol : enemyCol,
            title: Center(
              child: Text(
                enemyDied ? "You win!" : "You lose!",
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  gameStarted = false;
                  resetScore();
                  resetGame();
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                      padding: EdgeInsets.all(7),
                      color: Colors.white,
                      child: Text(
                        "Play Again",
                        style:
                            TextStyle(color: enemyDied ? playerCol : enemyCol),
                      )),
                ),
              )
            ],
          );
        });
  }

  void incMaxScore() {
    setState(() {
      maxScore++;
    });
  }

  void decMaxScore() {
    if (maxScore > 1) {
      setState(() {
        maxScore--;
      });
    }
  }

  Stack startScreen() {
    return !gameStarted
        ? Stack(children: [
            Container(
                alignment: Alignment(0.2, 0.2),
                child: IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.grey[400],
                  onPressed: incMaxScore,
                )),
            Container(
                alignment: Alignment(-0.2, 0.2),
                child: IconButton(
                  icon: Icon(Icons.remove),
                  color: Colors.grey[400],
                  onPressed: decMaxScore,
                )),
            Container(
              alignment: Alignment(0, 0.2),
              child: Text(
                maxScore.toString(),
                style: TextStyle(color: Colors.grey[400], fontSize: 30),
              ),
            ),
            Container(
                alignment: Alignment(0, -0.4),
                child: GestureDetector(
                  onTap: startGame,
                  child: Text(
                    'Press to start',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                  ),
                ))
          ])
        : Stack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Stack(
          children: [
            startScreen(),
            //top brick
            Brick(enemyX, -0.9, brickWidth, brickHeight, true, enemyCol),
            //score
            Score(gameStarted, enemyScore, playerScore),
            //ball
            Ball(ballX, ballY, ballSize),
            //bottom brick
            GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails update) =>
                    movePlayer(update),
                child: Brick(
                    playerX, 0.9, brickWidth, brickHeight, false, playerCol)),
          ],
        )));
  }
}

class Score extends StatelessWidget {
  late final gameStarted;
  late final enemyScore;
  late final playerScore;
  Score(this.gameStarted, this.enemyScore, this.playerScore);

  @override
  Widget build(BuildContext context) {
    return gameStarted
        ? Stack(children: [
            Container(
                alignment: Alignment(0, 0),
                child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 3,
                    color: Colors.grey[400])),
            Container(
                alignment: Alignment(0, -0.3),
                child: Text(
                  enemyScore.toString(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 100),
                )),
            Container(
                alignment: Alignment(0, 0.3),
                child: Text(
                  playerScore.toString(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 100),
                )),
          ])
        : Container();
  }
}
