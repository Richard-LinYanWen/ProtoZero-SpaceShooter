import 'package:flame/components.dart';
import 'player.dart';
import 'dart:math';

class LifeDisplay extends Component with HasGameRef {
  final Player player;
  final double heartSize;
  final double spacing;

  LifeDisplay({
    required this.player,
    this.heartSize = 45,
    this.spacing = 4,
  });

  final List<SpriteComponent> hearts = [];
  int? flickerHeartIndex; // index of heart currently flickering

  @override
  Future<void> onLoad() async {
    // create hearts
    for (int i = 0; i < player.lives; i++) {
      final sprite = await Sprite.load('Heart.png');
      final heart = SpriteComponent(
        sprite: sprite,
        size: Vector2.all(heartSize),
        position: Vector2(i * (heartSize + spacing), 45),
        priority: 100, // ensures hearts stay on top
      );
      hearts.add(heart);
      add(heart);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If player is invincible, flicker the last lost heart
    if (player.isInvincible && player.lives < hearts.length) {
      flickerHeartIndex = player.lives; // the heart to flicker
      final t = DateTime.now().millisecondsSinceEpoch / 100.0;
      // flicker by toggling opacity
      hearts[flickerHeartIndex!].opacity = (sin(t * 3) > 0) ? 1.0 : 0.0;
    } else {
      flickerHeartIndex = null;
    }

    // Update hearts opacity according to player.lives
    for (int i = 0; i < hearts.length; i++) {
      if (flickerHeartIndex != null && i == flickerHeartIndex) continue;
      hearts[i].opacity = (i < player.lives) ? 1.0 : 0.0;
    }
  }
}