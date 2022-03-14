import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:klotski/game/components/hud_component.dart';
import 'package:klotski/game/models/piece_position.dart';

import '../components/hit_component.dart';
import '../components/piece.dart';

class GameController {
  double tileWidth;
  List<HintComponent> hints;
  ComponentSet children;

  GameController(this.tileWidth, this.hints, this.children);

  List<Direction> potentialMoves(Vector2 position, Piece piece) {
    if (piece.width == piece.height) {
      //pawn
      if (piece.width == tileWidth) {
        return _potentialPawnMoves(position);
      } // commander
      else {
        return _potentialCommanderMoves(position);
      }
    } else if (piece.height - piece.width == piece.width) {
      return _potentialVerticalRectangleMoves(position);
    } else {
      return _potentialHorizontalRectangleMoves(position);
    }
  }

  List<int> getTimeAndStepInfo() {
    return [
      ((children.firstWhere((value) => value is TimeHudComponent)
              as TimeHudComponent)
          .currentValue),
      ((children.firstWhere((value) => value is StepHudComponent)
              as StepHudComponent)
          .currentValue)
    ];
  }

  void showHints(List<Direction> potentialMoves, Piece piece) {
    for (var value in potentialMoves) {
      switch (value) {
        case Direction.up:
          hints.firstWhere((element) => !element.taken)
            ..x = piece.x
            ..y = piece.y - tileWidth
            ..taken = true;

          if (piece.width / tileWidth != 1) {
            hints.firstWhere((element) => !element.taken)
              ..x = piece.x + tileWidth
              ..y = piece.y - tileWidth
              ..taken = true;
          }
          break;
        case Direction.down:
          var d = piece.height / tileWidth;
          hints.firstWhere((element) => !element.taken)
            ..x = piece.x
            ..y = piece.y + d * tileWidth
            ..taken = true;
          if (piece.width / tileWidth != 1) {
            hints.firstWhere((element) => !element.taken)
              ..x = piece.x + tileWidth
              ..y = piece.y + d * tileWidth
              ..taken = true;
          }
          break;
        case Direction.left:
          hints.firstWhere((element) => !element.taken)
            ..x = piece.x - tileWidth
            ..y = piece.y
            ..taken = true;
          if (piece.height / tileWidth != 1) {
            hints.firstWhere((element) => !element.taken)
              ..x = piece.x - tileWidth
              ..y = piece.y + tileWidth
              ..taken = true;
          }
          break;
        case Direction.right:
          var hintComponent = hints.firstWhere((element) => !element.taken);
          if (piece.width == tileWidth) {
            hintComponent
              ..x = piece.x + tileWidth
              ..y = piece.y
              ..taken = true;
          } else {
            hintComponent
              ..x = piece.x + tileWidth * 2
              ..y = piece.y
              ..taken = true;
          }
          if (piece.height / tileWidth != 1) {
            var hintComponent = hints.firstWhere((element) => !element.taken);
            if (piece.width == tileWidth * 2) {
              hintComponent
                ..x = piece.x + tileWidth * 2
                ..y = piece.y + tileWidth
                ..taken = true;
            } else {
              hintComponent
                ..x = piece.x + tileWidth
                ..y = piece.y + tileWidth
                ..taken = true;
            }
          }
          break;
        case Direction.center:
          break;
      }
    }
  }

  List<Direction> _potentialPawnMoves(Vector2 position) {
    List<Direction> directions = [];
    bool canMoveUp = position.y != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y - tileWidth / 2)));
    if (canMoveUp) {
      directions.add(Direction.up);
    }

    bool canMoveDown = position.y != tileWidth * 4 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y + tileWidth * 1.5)));
    if (canMoveDown) {
      directions.add(Direction.down);
    }

    bool canMoveLeft = position.x != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth / 2)));
    if (canMoveLeft) {
      directions.add(Direction.left);
    }

    bool canMoveRight = position.x != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth / 2)));

    if (canMoveRight) {
      directions.add(Direction.right);
    }
    return directions;
  }

  List<Direction> _potentialCommanderMoves(Vector2 position) {
    List<Direction> directions = [];
    bool canMoveUp = position.y != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y - tileWidth / 2))) &&
        !children.any(((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y - tileWidth / 2))));

    if (canMoveUp) {
      directions.add(Direction.up);
    }

    bool canMoveDown = position.y != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y + tileWidth * 2.5))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth * 2.5)));
    if (canMoveDown) {
      directions.add(Direction.down);
    }

    bool canMoveLeft = position.x != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth * 1.5)));
    if (canMoveLeft) {
      directions.add(Direction.left);
    }

    bool canMoveRight = position.x != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 2.5, position.y + tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 2.5, position.y + tileWidth * 1.5)));
    if (canMoveRight) {
      directions.add(Direction.right);
    }

    return directions;
  }

  List<Direction> _potentialVerticalRectangleMoves(Vector2 position) {
    List<Direction> directions = [];

    bool canMoveUp = position.y != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y - tileWidth / 2)));
    if (canMoveUp) {
      directions.add(Direction.up);
    }

    bool canMoveDown = position.y != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y + tileWidth * 2.5)));
    if (canMoveDown) {
      directions.add(Direction.down);
    }

    bool canMoveLeft = position.x != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth * 1.5)));
    if (canMoveLeft) {
      directions.add(Direction.left);
    }

    bool canMoveRight = position.x != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth * 1.5)));
    if (canMoveRight) {
      directions.add(Direction.right);
    }

    return directions;
  }

  List<Direction> _potentialHorizontalRectangleMoves(Vector2 position) {
    List<Direction> directions = [];

    bool canMoveUp = position.y != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y - tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y - tileWidth / 2)));
    if (canMoveUp) {
      directions.add(Direction.up);
    }

    bool canMoveDown = position.y != tileWidth * 4 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y + tileWidth * 1.5))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth * 1.5)));
    if (canMoveDown) {
      directions.add(Direction.down);
    }

    bool canMoveLeft = position.x != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth / 2)));
    if (canMoveLeft) {
      directions.add(Direction.left);
    }

    bool canMoveRight = position.x != tileWidth * 2 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 2.5, position.y + tileWidth / 2)));
    if (canMoveRight) {
      directions.add(Direction.right);
    }

    return directions;
  }

  int cellIndex(Piece piece) {
    double x = piece.x + tileWidth / 2;
    double y = piece.y + tileWidth / 2;
    int index = -1;
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 4; j++) {
        index++;
        var xWithinRange = x > j * tileWidth && x < (j + 1) * tileWidth;
        var yWithinRange = y > i * tileWidth && y < (i + 1) * tileWidth;
        if (xWithinRange && yWithinRange) {
          return index;
        }
      }
    }
    throw RangeError('position($x,$y) are not valid');
  }

  Future<List<Piece>> layoutPieces(List<PiecePosition> piecePositions,
      FlameGame game, VoidCallback caoCao, VoidCallback nonCaoCao) async {
    List<Piece> pieces = [];
    for (PiecePosition piecePosition in piecePositions) {
      var pieceInfo = piecePosition.info;
      var dimension = pieceInfo.dimension;
      var index = piecePosition.index;
      var piece = Piece(
          sprite: Sprite(await Flame.images.load(pieceInfo.icon)),
          info: pieceInfo);
      if (pieceInfo == PieceInfo.caoCao) {
        piece.callback = caoCao;
      } else {
        piece.callback = nonCaoCao;
      }
      pieces.add(piece);
      game.add(piece
        ..x = (index % 4) * tileWidth
        ..y = ((index / 4).floor()) * tileWidth
        ..width = dimension.x * tileWidth
        ..height = dimension.y * tileWidth
        ..recordPosition());
    }
    return pieces;
  }
}
