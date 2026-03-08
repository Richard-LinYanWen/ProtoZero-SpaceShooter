import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_page.dart';
import 'dart:math';
import 'player.dart';
import 'life_display.dart';
import 'enemy_type_1.dart';
import 'projectile.dart';
import 'background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StartPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/Space_Nebula.png',
              fit: BoxFit.cover,
            ),
          ),

          /// Menu Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                /// Game Icon
                SizedBox(
                  width: 256,
                  height: 256,
                  child: Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.contain,
                    ),
                ),

                /// Reuse Player animation from Flame
                SizedBox(
                  width: 128,
                  height: 128,
                  child: GameWidget(
                    game: PlayerPreviewGame(),
                  ),
                ),

                /// Start Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    // ← THIS IS WHERE NAVIGATION GOES
                    final game = SpaceShooterGame();  // create the game instance
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GamePage(game: game), // wrap in GamePage
                      ),
                    );
                  },
                  child: const Text("Start", style: TextStyle(fontSize: 20)),
                ),

                /// Exit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text("Exit", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpaceShooterGame extends FlameGame with HasCollisionDetection {
  late Player player;

  final Random rand = Random();
  double enemySpawnTimer = 0;

  bool isGameOver = false;
  final ValueNotifier<bool> gameOverNotifier = ValueNotifier(false);

  int score = 0;
  int enemiesOneKilled = 0;
  double enemySpawnRate = 0.5; // seconds between spawns, will decrease as score increases

  @override
  Future<void> onLoad() async {

    /// Background
    add(Background());

    /// Player
    player = Player()
      ..position = Vector2(
      size.x / 2,
      size.y * 0.75,
    );

    await add(player);

    // Spawn 7 Pascal enemies total at start (counting 2+5 from update if screen is empty)
    for (int i = 0; i < 2; i++) {
      spawnEnemy();
    }

    // HUD Components (top-most layer)
    add(LifeDisplay(player: player)..priority = 100);   // hearts
    add(ScoreDisplay(game: this)..priority = 100);      // score
  }

  void resetGame() {
    // Remove all projectiles
    children.whereType<Projectile>().toList().forEach((projectile) {
      projectile.removeFromParent();
    });

    // Remove all enemies
    children.whereType<EnemyType1>().toList().forEach((enemy) {
      enemy.removeFromParent();
    });

    // Reset player
    player.lives = 3;
    player.position = Vector2(size.x / 2, size.y * 0.75);
    player.isInvincible = false;
    player.invincibilityTimer = 0;

    // Reset game state
    score = 0;
    isGameOver = false;
    gameOverNotifier.value = false; // reset overlay notifier

    // Reset enemy timer
    enemySpawnTimer = 0;

    // Spawn starting enemies again
    for (int i = 0; i < 3; i++) {
      spawnEnemy();
    }

    // Resume the game if paused
    resumeEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(isGameOver) return;

    enemySpawnTimer += dt;

    if (enemySpawnTimer > 2) {
      spawnEnemy();
      enemySpawnTimer = 0;
    }

    // --- Auto-add 5 enemies if none are on screen ---
    final currentEnemies = children.whereType<EnemyType1>().toList();
    if (currentEnemies.isEmpty && !isGameOver) {
      for (int i = 0; i < 5; i++) {
        spawnEnemy();
      }
    }

    void updateScore(int points) {
      score += points;

      // Every 10 points, boost spawn rate
      if (score % 10 == 0 && score != 0) {
        enemySpawnRate /= 1.5; // decrease interval = increase rate
      }
    }

    void enemyOneKilled(EnemyType1 enemy) {
      enemy.removeFromParent();
      enemiesOneKilled++;

      updateScore(1);

      // Spawn a new EnemyType1 for every 3 kills
      if (enemiesOneKilled % 3 == 0) {
        spawnEnemy();
      }
    }

    // Collision detection
    for (final enemy in children.whereType<EnemyType1>()) {
      if (!player.isInvincible &&
          player.toRect().overlaps(enemy.toRect())) {
        player.onHit();
        // Optional: you can remove or bounce enemy
      }
    }

    // Optional: check for game over
    if (player.lives <= 0) {
      isGameOver = true;
      endGame();
      pauseEngine();
    }
  }

  void endGame() {
    isGameOver = true;
    gameOverNotifier.value = true; // trigger Game Over overlay
    pauseEngine();
  }

  void spawnEnemy() {
    if (isGameOver) return;

    const double minDistance = 80; // minimum spacing between enemies
    Vector2 spawnPos = Vector2.zero();
    bool validPosition = false;

    while (!validPosition) {
      final edge = rand.nextInt(3);

      if (edge == 0) {
        /// top edge
        spawnPos = Vector2(
          rand.nextDouble() * size.x,
          0,
        );
      } else if (edge == 1) {
        /// left edge (upper half)
        spawnPos = Vector2(
          0,
          rand.nextDouble() * size.y * 0.5,
        );
      } else {
        /// right edge (upper half)
        spawnPos = Vector2(
          size.x,
          rand.nextDouble() * size.y * 0.5,
        );
      }

      validPosition = true;

      /// check distance from all existing enemies
      for (final enemy in children.whereType<EnemyType1>()) {
        if (enemy.position.distanceTo(spawnPos) < minDistance) {
          validPosition = false;
          break;
        }
      }
    }

    final enemy = EnemyType1()..position = spawnPos;

    // --- UNSTUCK FIX ---
    Vector2 screenCenter = Vector2(size.x / 2, size.y / 2);
    Vector2 pushDirection = (screenCenter - spawnPos).normalized();
    enemy.velocity = pushDirection * 150; // adjust speed if needed

    add(enemy);
  }
}

class PlayerPreviewGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000); // transparent
  final player = Player()..enableShooting = false; // disable shooting in preview

  @override
  Future<void> onLoad() async {
    final player = Player()
      ..position = Vector2(64, 64); // center of the 128x128 box

    add(player);
  }
}

class GameOverOverlay extends StatelessWidget {
  final SpaceShooterGame game;
  final int score;

  const GameOverOverlay({super.key, required this.game, required this.score});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "Game Over...",
              style: TextStyle(fontSize: 36, color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              "Score: $score",
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              onPressed: () {
                // Restart the game
                game.overlays.remove('GameOverOverlay');
                game.resetGame();
              },
              child: const Text("Play Again", style: TextStyle(fontSize: 20)),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              onPressed: () {
                SystemNavigator.pop(); // exit app
              },
              child: const Text("Exit", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreDisplay extends TextComponent with HasGameRef<SpaceShooterGame> {
  final SpaceShooterGame game;

  ScoreDisplay({required this.game})
      : super(
          text: 'Score: 0',
          anchor: Anchor.topLeft,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          priority: 100, // always drawn on top
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Now gameRef is available
    position = Vector2(16, gameRef.size.y - 48); 
  }

  @override
  void update(double dt) {
    super.update(dt);
    text = 'Score: ${game.score}';
  }
}