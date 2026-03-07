import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'enemy_type_1.dart';
import 'main.dart';

class Projectile extends SpriteComponent
    with CollisionCallbacks, HasGameRef {

  final double speed = 400; // pixels per second

  Projectile({required Vector2 startPosition})
      : super(
          size: Vector2.all(32), // original size
          anchor: Anchor.center,   // ← center the projectile on position
        ) {
    position = startPosition;
  }

  @override
  Future<void> onLoad() async {
    final spriteImage = await gameRef.images.load('ProZect.png');
    priority = 5; // ensure projectiles are drawn below player
    sprite = Sprite(spriteImage);

    // Make it 2x bigger
    size *= 2; // now size is 64x64

    // Add hitbox for collision detection
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move projectile upward
    position.add(Vector2(0, -1) * speed * dt);

    // Remove if off-screen
    if (position.y + size.y / 2 < 0) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is EnemyType1) {
      other.removeFromParent(); // remove enemy
      removeFromParent();       // remove projectile
      
      // increase score
      if (gameRef is SpaceShooterGame) {
        (gameRef as SpaceShooterGame).score += 1;
      }
    }
  }
}