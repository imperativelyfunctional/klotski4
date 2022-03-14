import 'package:flutter/material.dart';
import 'package:klotski/gallery/game_preview.dart';

import '../game/game.dart';
import '../game/models/piece_position.dart';
import '../main/game_arguments.dart';

class GameGallery extends StatefulWidget {
  final List<Mission> missions;

  const GameGallery({Key? key, required this.missions}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GameGalleryState();
}

class GameGalleryState extends State<GameGallery> {
  List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    double spacing = 10;
    int crossAxisCount = 2;
    var dimension =
        (MediaQuery.of(context).size.width - spacing * (crossAxisCount - 1)) /
            (crossAxisCount * 4);

    var missions = widget.missions;
    return SafeArea(
      child: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/lubu.jpg'),
                      opacity: 0.2,
                      fit: BoxFit.cover)),
              child: Image.asset('assets/images/hrd_2.png'),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 4 / 6,
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing),
                itemBuilder: (BuildContext context, int index) {
                  var mission = missions[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Game(),
                        settings: RouteSettings(
                            name: 'game',
                            arguments: GameArguments(
                                newGame: true, index: mission.id)))),
                    child: MissionPreview(
                      dimension: dimension,
                      mission: mission,
                      color: colors[index % 7],
                    ),
                  );
                },
                itemCount: missions.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
