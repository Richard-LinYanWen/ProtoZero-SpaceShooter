import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'main.dart'; // import SpaceShooterGame

class GamePage extends StatefulWidget {
  final SpaceShooterGame game;
  const GamePage({super.key, required this.game});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool paused = false;
  bool showGameOver = false;

  @override
  void initState() {
    super.initState();

    // Listen to game over notifier
    widget.game.gameOverNotifier.addListener(() {
      if (mounted) {
        setState(() {
          showGameOver = widget.game.isGameOver;
        });
      }
    });
  }

  void togglePause() {
    setState(() {
      paused = !paused;
      if (paused) {
        widget.game.pauseEngine();
      } else {
        widget.game.resumeEngine();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      body: Stack(
        children: [

          //game widget
          GameWidget(game: game),

          // Pause button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              iconSize: 40,
              color: Colors.white,
              icon: Icon(paused ? Icons.play_arrow : Icons.pause),
              onPressed: togglePause,
            ),
          ),

          // Pause overlay
          if (paused)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Paused",
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: togglePause,
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Exit",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Game Over overlay
          if (showGameOver)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Game Over...",
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Score: ${widget.game.score}",
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        widget.game.resetGame();
                        setState(() {
                          paused = false;
                          showGameOver = false;
                        });
                      },
                      child: const Text("Play Again", style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Exit", style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }
} // <- make sure this closing brace exists!