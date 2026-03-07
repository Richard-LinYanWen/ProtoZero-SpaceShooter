import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'main.dart'; // import your SpaceShooterGame class

class EnemyType1 extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<SpaceShooterGame> {
  EnemyType1() : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Load the sprite from the game's image cache
    final image = await gameRef.images.load('Pascal.png');

    // 1 column, 2 rows
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 2,           // 2 frames total
        stepTime: 0.25,      // animation speed
        textureSize: Vector2(
          image.width.toDouble(),
          image.height / 2,  // 2 rows
        ),
        amountPerRow: 1,     // 1 column
      ),
    );

    // Give it a random initial velocity
    final rand = Random();
    velocity = Vector2(
      rand.nextDouble() * 200 - 100, // -100 to 100
      rand.nextDouble() * 200 - 100,

    );
    // Add hitbox for collision detection
    add(RectangleHitbox());
  }

  Vector2 velocity = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);

    // Move the enemy
    position += velocity * dt;

    // Bounce off the screen edges
    if (position.x < 0 || position.x > gameRef.size.x) velocity.x = -velocity.x;
    if (position.y < 0 || position.y > gameRef.size.y) velocity.y = -velocity.y;
  }
}