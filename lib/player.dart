import 'dart:ui'; // for Color and Paint
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart'; // optional if you use Colors
import 'projectile.dart';
import 'dart:math';

class Player extends SpriteAnimationComponent with CollisionCallbacks, DragCallbacks, HasGameRef {
  Player() : super(size: Vector2(64, 64));

  int lives = 3;
  bool isInvincible = false;
  double invincibilityTimer = 0;

  bool enableShooting = true; // control shooting behavior
  double shootCooldown = 0;
  final double shootInterval = 0.5; // seconds between shots

  @override
  Future<void> onLoad() async {
    final image = await Flame.images.load('ProtoZero.png');
    priority = 10; // ensure player is drawn above background
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: Vector2(
          image.width / 2,
          image.height / 2,
        ),
        amountPerRow: 2,
      ),
    );
    anchor = Anchor.center;
    scale = Vector2.all(2);

    // Add hitbox
    add(RectangleHitbox());
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.canvasDelta;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (enableShooting) {
      shootCooldown += dt;
      if (shootCooldown >= shootInterval) {
        shootCooldown = 0;
        shoot();
      }
    }

    if (isInvincible) {
      invincibilityTimer += dt;

      // Flicker effect
      final alpha = (invincibilityTimer * 10 % 2) > 1 ? 1.0 : 0.0;
      paint = Paint()..color = Color.fromRGBO(255, 255, 255, alpha);

      // Turn off invincibility after 0.5 seconds
      if (invincibilityTimer >= 1.0) {
        isInvincible = false;
        invincibilityTimer = 0;
        paint = Paint()..color = const Color.fromRGBO(255, 255, 255, 1);
      }
    }
  }

  /// Call this when player is hit
  void onHit() {
    if (!isInvincible) {
      lives--;            // reduce life
      isInvincible = true; // start invincibility
      invincibilityTimer = 0; // reset timer
    }
  }

  //shooting
  void shoot() {
    final projectile = Projectile(
        startPosition: position.clone(),
      );
      gameRef.add(projectile);
  }
}
