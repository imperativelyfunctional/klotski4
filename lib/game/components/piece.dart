import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

enum Direction { up, down, left, right, center }

enum PieceInfo {
  guanYu, //0
  bingLeft, //1
  bingRight, //2
  caoCao, //3
  zhaoYun, //4
  zhangFei, //5
  huangZhong, //6
  maChao, //7
}

extension PieceNameExtension on PieceInfo {
  String get icon {
    switch (this) {
      case PieceInfo.guanYu:
        return 'guanyu.jpg';
      case PieceInfo.bingLeft:
        return 'pawn.jpg';
      case PieceInfo.bingRight:
        return 'pawn2.jpg';
      case PieceInfo.zhangFei:
        return 'zhangfei.jpg';
      case PieceInfo.zhaoYun:
        return 'zhaoyun.jpg';
      case PieceInfo.maChao:
        return 'machao.jpg';
      case PieceInfo.caoCao:
        return 'caocao.jpg';
      case PieceInfo.huangZhong:
        return 'huangzhong.jpg';
    }
  }
}

extension PieceDimenstionExtension on PieceInfo {
  Vector2 get dimension {
    switch (this) {
      case PieceInfo.guanYu:
        return Vector2(2, 1);
      case PieceInfo.bingLeft:
        return Vector2(1, 1);
      case PieceInfo.bingRight:
        return Vector2(1, 1);
      case PieceInfo.zhangFei:
        return Vector2(1, 2);
      case PieceInfo.zhaoYun:
        return Vector2(1, 2);
      case PieceInfo.maChao:
        return Vector2(1, 2);
      case PieceInfo.caoCao:
        return Vector2(2, 2);
      case PieceInfo.huangZhong:
        return Vector2(1, 2);
      default:
        return Vector2(1, 2);
    }
  }
}

class Movement {
  Direction direction;
  Vector2 destination;

  Movement({required this.direction, required this.destination});
}

class Piece extends SpriteComponent {
  final speed = 500;
  final List<Movement> movements = [];
  PieceInfo info;
  int currentIndex = 0;
  late Effect effect;
  late VoidCallback? callback;

  Piece({required Sprite sprite, this.callback, required this.info})
      : super(sprite: sprite);

  void recordPosition() {
    movements
        .add(Movement(direction: Direction.center, destination: Vector2(x, y)));
  }

  void addEffect(Effect effect) {
    add(effect);
    this.effect = effect;
    effect.resume();
  }

  void playEffect() {
    effect.reset();
    effect.resume();
  }

  void stopEffect() {
    effect.reset();
    effect.pause();
  }

  @override
  void update(double dt) {
    if (currentIndex < movements.length) {
      final movement = movements[currentIndex];
      final destination = movement.destination;
      var destinationX = destination.x;
      var destinationY = destination.y;
      switch (movement.direction) {
        case Direction.right:
          {
            if (x + dt * speed > destinationX) {
              x = destinationX;
              if (callback != null) {
                callback!();
              }
            } else {
              x += dt * speed;
            }
            if (x == destinationX) {
              currentIndex++;
            }
            break;
          }
        case Direction.left:
          {
            if (x - dt * speed < destinationX) {
              x = destinationX;
              if (callback != null) {
                callback!();
              }
            } else {
              x -= dt * speed;
            }
            if (x == destinationX) {
              currentIndex++;
            }
            break;
          }
        case Direction.up:
          {
            if (y - dt * speed < destinationY) {
              y = destinationY;
              if (callback != null) {
                callback!();
              }
            } else {
              y -= dt * speed;
            }
            if (y == destinationY) {
              currentIndex++;
            }
            break;
          }
        case Direction.down:
          {
            if (y + dt * speed > destinationY) {
              y = destinationY;
              if (callback != null) {
                callback!();
              }
            } else {
              y += dt * speed;
            }
            if (y == destinationY) {
              currentIndex++;
            }
            break;
          }
        case Direction.center:
          {
            currentIndex++;
            break;
          }
      }
    }
  }

  void addAnimation(Movement movement) {
    movements.add(movement);
  }
}
