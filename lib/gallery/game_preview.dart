import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klotski/game/components/piece.dart';
import 'package:klotski/game/models/piece_position.dart';

class MissionPreview extends StatefulWidget {
  final double dimension;
  final Mission mission;
  final Color color;

  const MissionPreview(
      {Key? key,
      required this.dimension,
      required this.mission,
      required this.color})
      : super(key: key);

  @override
  State createState() {
    return MissionPreviewState();
  }
}

class MissionPreviewState extends State<MissionPreview> {
  ui.Image? image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    var dimension = widget.dimension;
    return image == null
        ? Container(
            color: Colors.blueAccent,
          )
        : Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                image: const DecorationImage(
                    image: AssetImage('assets/images/map.jpg'),
                    fit: BoxFit.cover)),
            child: CustomPaint(
                painter: GameLayoutPainter(
                    image!, dimension, widget.mission, widget.color)),
          );
  }

  _loadImage() async {
    ui.Image image = await getImage('assets/images/sprite_sheet.png');
    setState(() {
      this.image = image;
    });
  }

  Future<ui.Image> getImage(String imagePath) async {
    final data = await rootBundle.load(imagePath);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    return image;
  }
}

class GameLayoutPainter extends CustomPainter {
  final ui.Image image;
  final double dimension;
  final Mission mission;
  final Color color;

  const GameLayoutPainter(this.image, this.dimension, this.mission, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    int unit = 100;
    canvas.drawRect(Rect.fromLTWH(0, 0, dimension * 4, dimension * 5),
        Paint()..color = color.withAlpha(225));
    for (var piecePosition in mission.piecePositions) {
      var spriteSheet = getSpriteSheet()[piecePosition.info]!;
      double x = spriteSheet % 4;
      double y = (spriteSheet / 4).floor().toDouble();
      var pieceDimension = piecePosition.info.dimension;
      canvas.drawImageRect(
          image,
          Rect.fromLTWH(x * unit, y * unit, pieceDimension.x * unit,
              pieceDimension.y * unit),
          Rect.fromLTWH(
              (piecePosition.index % 4) * dimension,
              (piecePosition.index / 4).floor() * dimension,
              pieceDimension.x * dimension,
              pieceDimension.y * dimension),
          paint);

      var borderColor = Colors.deepPurple;
      final textPainter = TextPainter(
        text: TextSpan(
          text: mission.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
            shadows: [
              Shadow(
                  // bottomLeft
                  offset: const Offset(-1.5, -1.5),
                  color: borderColor),
              Shadow(
                  // bottomRight
                  offset: const Offset(1.5, -1.5),
                  color: borderColor),
              Shadow(
                  // topRight
                  offset: const Offset(1.5, 1.5),
                  color: borderColor),
              Shadow(
                  // topLeft
                  offset: const Offset(-1.5, 1.5),
                  color: borderColor),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      final xCenter = (size.width - textPainter.width) / 2;
      final yCenter = size.height - dimension + textPainter.height / 2;
      final offset = Offset(xCenter, yCenter);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Map<PieceInfo, int> getSpriteSheet() {
  Map<PieceInfo, int> sheet = {};
  sheet[PieceInfo.guanYu] = 0;
  sheet[PieceInfo.zhangFei] = 2;
  sheet[PieceInfo.zhaoYun] = 3;
  sheet[PieceInfo.bingLeft] = 4;
  sheet[PieceInfo.bingRight] = 5;
  sheet[PieceInfo.caoCao] = 8;
  sheet[PieceInfo.maChao] = 10;
  sheet[PieceInfo.huangZhong] = 11;
  return sheet;
}
