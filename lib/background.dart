import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'main.dart';

class Background extends SpriteComponent with HasGameRef<SpaceShooterGame> {

  @override
  Future<void> onLoad() async {
    final image = await gameRef.images.load('Space_Nebula.png');

    // Screen ratio
    final screenRatio = gameRef.size.x / gameRef.size.y;

    // Image ratio
    final imageRatio = image.width / image.height;

    Vector2 srcSize;
    Vector2 srcPosition = Vector2.zero();

    if (imageRatio > screenRatio) {
      // Image is wider → crop left/right
      final newWidth = image.height * screenRatio;
      final offsetX = (image.width - newWidth) / 2;

      srcSize = Vector2(newWidth, image.height.toDouble());
      srcPosition = Vector2(offsetX, 0);
    } else {
      // Image is taller → crop top/bottom
      final newHeight = image.width / screenRatio;
      final offsetY = (image.height - newHeight) / 2;

      srcSize = Vector2(image.width.toDouble(), newHeight);
      srcPosition = Vector2(0, offsetY);
    }

    sprite = Sprite(
      image,
      srcPosition: srcPosition,
      srcSize: srcSize,
    );

    size = gameRef.size; // fill screen
    position = Vector2.zero();
    priority = -10;
  }
}