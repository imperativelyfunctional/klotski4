import 'dart:async' as async;
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:klotski/game/controller/game_controller.dart';
import 'package:klotski/game/models/piece_position.dart';
import 'package:klotski/main/game_arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/hit_component.dart';
import 'components/hud_component.dart';
import 'components/menu_button.dart';
import 'components/piece.dart';

class Game extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var gameArguments =
        ModalRoute.of(context)!.settings.arguments! as GameArguments;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GameWidget(game: Klotski(gameArguments)),
      ),
    );
  }
}

class Klotski extends FlameGame with PanDetector {
  bool running = true;
  late double tileWidth;
  Piece? current;
  late SpriteAnimationComponent victory;
  late AudioPlayer? playingBGM;
  List<HintComponent> hints = [];
  late GameController controller;
  late String name;
  late int id;
  late bool musicOn;
  late bool sfxOn;
  late SharedPreferences pref;
  GameArguments gameArguments;

  Klotski(this.gameArguments);

  @override
  void onPanDown(DragDownInfo info) async {
    var touchPoint = info.eventPosition.game;
    if (running) {
      children.any((element) {
        if (element is Piece) {
          var potentialMoves =
              controller.potentialMoves(Vector2(element.x, element.y), element);
          if (element.containsPoint(touchPoint) && potentialMoves.isNotEmpty) {
            controller.cellIndex(element);
            if (sfxOn) {
              FlameAudio.audioCache.play('pickup.mp3');
            }
            current = element;
            controller.showHints(potentialMoves, element);
            current!.addEffect(ColorEffect(
              Colors.yellow,
              const Offset(
                0.0,
                0.4,
              ),
              EffectController(
                duration: 0.5,
                reverseDuration: 0.5,
                infinite: true,
              ),
            ));
            return true;
          }
        }
        return false;
      });
    } else {
      children.any((element) {
        if (element is MenuButton && element.containsPoint(touchPoint)) {
          element.setOnState(true);
          element.onClick();
          return true;
        }
        return false;
      });
    }

    super.onPanDown(info);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (current != null && running) {
      var touchPoint = info.eventPosition.game;
      var delta = info.delta.game;
      var initialPosition = current!.movements.last.destination;
      var potentialMoves = controller.potentialMoves(initialPosition, current!);
      if (delta.x > 0) {
        potentialMoves.any((element) {
          if (element == Direction.right) {
            if (touchPoint.x >=
                initialPosition.x + current!.width + tileWidth / 2) {
              current!.addAnimation(Movement(
                  direction: Direction.right,
                  destination: Vector2(
                      initialPosition.x + tileWidth, initialPosition.y)));
            }
            return true;
          }
          return false;
        });
      } else {
        potentialMoves.any((element) {
          if (element == Direction.left) {
            if (touchPoint.x + tileWidth / 2 <= initialPosition.x) {
              current!.addAnimation(Movement(
                  direction: Direction.left,
                  destination: Vector2(
                      initialPosition.x - tileWidth, initialPosition.y)));
            }
            return true;
          }
          return false;
        });
      }
      if (delta.y > 0) {
        potentialMoves.any((element) {
          if (element == Direction.down) {
            if (touchPoint.y >=
                initialPosition.y + current!.height + tileWidth / 2) {
              current!.addAnimation(Movement(
                  direction: Direction.down,
                  destination: Vector2(
                      initialPosition.x, initialPosition.y + tileWidth)));
            }
            return true;
          }
          return false;
        });
      } else {
        potentialMoves.any((element) {
          if (element == Direction.up) {
            if (touchPoint.y + tileWidth / 2 <= initialPosition.y) {
              current!.addAnimation(Movement(
                  direction: Direction.up,
                  destination: Vector2(
                      initialPosition.x, initialPosition.y - tileWidth)));
            }
            return true;
          }
          return false;
        });
      }
    }
    super.onPanUpdate(info);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (running) {
      if (current != null) {
        if (sfxOn) {
          FlameAudio.audioCache.play('dropoff.mp3');
        }
      }
      for (var hint in hints) {
        hint.x = -200;
        hint.y = -200;
        hint.taken = false;
      }
      current?.stopEffect();
      current = null;
      super.onPanEnd(info);
    } else {
      {
        for (var value in children) {
          if (value is MenuButton) {
            value.setOnState(false);
          }
        }
      }
    }
  }

  @override
  void onPanCancel() {
    if (running) {
      current = null;
    }
    super.onPanCancel();
  }

  @override
  void onRemove() {
    if (musicOn) {
      playingBGM!.pause();
    }
    _recordGameData();
    super.onRemove();
  }

  _recordGameData() async {
    List<PiecePosition> positions = [];
    for (var value in children) {
      if (value is Piece) {
        positions.add(PiecePosition(
            index: controller.cellIndex(value), info: value.info));
      }
    }
    var timeAndStepInfo = controller.getTimeAndStepInfo();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(
        'game',
        json.encode(Mission(id: id, name: name, piecePositions: positions)
          ..seconds = timeAndStepInfo[0]
          ..steps = timeAndStepInfo[1]));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    tileWidth = (size / 4).x;
    controller = GameController(tileWidth, hints, children);
    pref = await SharedPreferences.getInstance();
    musicOn = pref.getBool('music_on') ?? true;
    sfxOn = pref.getBool('sfx_on') ?? true;
    playingBGM = musicOn
        ? await FlameAudio.audioCache.loop('rain.mp3', volume: 0.1)
        : null;
    _buildGameBoard();
  }

  void _buildGameBoard() async {
    if (musicOn) {
      playingBGM!.resume();
    }
    children.removeWhere((element) => (element is Piece ||
        element is HintComponent ||
        element is TextComponent));
    hints.clear();
    running = true;
    add(SpriteComponent(
      sprite: Sprite(
        await images.load('lubu.jpg'),
      ),
    )
      ..x = 0
      ..y = 0
      ..width = tileWidth * 4
      ..height = tileWidth * 5);

    add(SpriteComponent(sprite: Sprite(await images.load('huarongdao.jpg')))
      ..x = tileWidth
      ..y = tileWidth * 4
      ..width = tileWidth * 2
      ..height = tileWidth);

    var color1 = Colors.blue.withAlpha(200);
    var color2 = Colors.lightGreen.withAlpha(200);

    var hintComponent =
        HintComponent(color1: color1, color2: color2, side: tileWidth);
    add(hintComponent);
    hints.add(hintComponent
      ..x = -200
      ..y = -200);
    var hintComponent2 =
        HintComponent(color1: color1, color2: color2, side: tileWidth);
    add(hintComponent2
      ..x = -200
      ..y = -200);
    hints.add(hintComponent2);
    Mission mission;
    List<PiecePosition> positions;
    if (gameArguments.newGame) {
      id = gameArguments.index!;
      mission = await _readMissionFromJson(id);
      positions = mission.piecePositions;
      name = mission.name;
    } else {
      var game = pref.getString('game');
      if (game == null) {
        mission = await _readMissionFromJson(1);
        positions = mission.piecePositions;
        name = mission.name;
        id = mission.id;
      } else {
        final jsonResult = json.decode(game);
        mission = Mission.fromJson(jsonResult);
        name = mission.name;
        id = mission.id;
        positions = mission.piecePositions;
      }
    }
    const padding = 10.0;
    var timeText =
        TimeHudComponent(color: Colors.amber, currentValue: mission.seconds);
    add(timeText
      ..anchor = Anchor.topLeft
      ..x = padding
      ..y = size.y - timeText.height);

    var stepText =
        StepHudComponent(color: Colors.lightGreen, currentValue: mission.steps);
    add(stepText
      ..anchor = Anchor.topRight
      ..x = size.x - stepText.width - padding
      ..y = size.y - timeText.height);

    await controller.layoutPieces(positions, this, () {
      stepText.currentValue++;
      children.any((element) {
        if (element is Piece &&
            element.y == tileWidth * 3 &&
            element.x == tileWidth &&
            element.width == element.height &&
            element.width == tileWidth * 2) {
          victory.setOpacity(1);
          if (musicOn) {
            playingBGM!.stop();
          }
          FlameAudio.audioCache.play('winner.mp3');
          showMenu();
          element.stopEffect();
          running = false;
          return true;
        }
        return false;
      });
    }, () => stepText.currentValue++);
    var map = await images.load('map.jpg');
    var remainingY = size.y - tileWidth * 5;
    var scaleFactor = _getTargetDimension(Vector2(tileWidth * 4, remainingY),
        Vector2(map.width.toDouble(), map.height.toDouble()));
    add(SpriteComponent(
      sprite: Sprite(
        map,
      ),
    )
      ..scale = Vector2(scaleFactor, scaleFactor)
      ..x = 0
      ..y = tileWidth * 5);

    victory = SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList(
        await Future.wait([0, 1, 2].map((i) => Sprite.load('victory_$i.png'))),
        stepTime: 0.3,
      ),
      size: Vector2.all(64.0),
    )
      ..x = tileWidth * 2
      ..y = tileWidth * 2.5
      ..width = tileWidth * 2
      ..anchor = Anchor.center
      ..height = tileWidth;
    victory.scale = Vector2(2, 2);
    victory.setOpacity(0);
    add(victory);

    add(TextComponent(
        text: name,
        textRenderer: TextPaint(
            style: TextStyle(
                shadows: const [
              Shadow(color: Colors.black87, offset: Offset(2, 2))
            ],
                fontSize: 40,
                color: BasicPalette.white.color,
                fontWeight: FontWeight.bold)))
      ..anchor = Anchor.topCenter
      ..x = size.x / 2
      ..y = tileWidth * 5);
  }

  async.Future<Mission> _readMissionFromJson(int id) async {
    String data = await DefaultAssetBundle.of(buildContext!)
        .loadString("assets/json/missions.json");
    return (json.decode(data) as List)
        .map((e) => Mission.fromJson(e))
        .toList()[id - 1];
  }

  void showMenu() {
    async.Timer(const Duration(seconds: 5), () async {
      victory.setOpacity(0);
      add(RectangleComponent(
          size: size,
          position: Vector2(0, 0),
          paint: Paint()..color = Colors.black.withAlpha(130)));
      var winningImage = await images.load('winning-menu.png');
      var menu = SpriteComponent(sprite: Sprite(winningImage))
        ..size = Vector2(
            size.x * .9, size.x * .9 * winningImage.height / winningImage.width)
        ..position = Vector2(size.x * .05, tileWidth);
      add(menu);
      var backImage = Sprite(await images.load('ingame-menu-back.png'));
      var backOnImage = Sprite(await images.load('ingame-menu-back-on.png'));
      add(MenuButton(
        normal: backImage,
        pressed: backOnImage,
        onClick: () => {Navigator.pop(buildContext!)},
      )
        ..size = Vector2(size.x * .45,
            size.x * .45 * backImage.image.height / backImage.image.width)
        ..position = Vector2(
            size.x * .05,
            tileWidth +
                size.x * .9 * winningImage.height / winningImage.width +
                20));

      var resetImage = Sprite(await images.load('ingame-menu-reset.png'));
      var resetOnImage = Sprite(await images.load('ingame-menu-reset-on.png'));
      add(MenuButton(
        normal: resetImage,
        pressed: resetOnImage,
        onClick: () => {_buildGameBoard()},
      )
        ..size = Vector2(size.x * .45,
            size.x * .45 * resetImage.image.height / resetImage.image.width)
        ..position = Vector2(
            size.x * .5,
            tileWidth +
                size.x * .9 * winningImage.height / winningImage.width +
                20));
    });
  }

  double _getTargetDimension(Vector2 target, Vector2 source) {
    if (target.x * source.y < target.y * source.x) {
      var xScale = source.x / target.x;
      var yScale = source.y / target.y;
      if (xScale < yScale) {
        return 1 / yScale;
      } else {
        return 1 / xScale;
      }
    } else {
      var xScale = target.x / source.x;
      var yScale = target.y / source.y;
      if (xScale > yScale) {
        return xScale;
      } else {
        return yScale;
      }
    }
  }
}
