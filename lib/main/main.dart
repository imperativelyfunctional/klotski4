import 'dart:convert';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:klotski/gallery/game_gallery.dart';
import 'package:klotski/main/game_arguments.dart';

import '../game/game.dart';
import '../game/models/piece_position.dart';
import 'components/switch_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _MainPage(),
  ));
}

class _MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/guanyu-unicorn.jpg'),
              fit: BoxFit.cover)),
      child: Column(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Image(
                  image: AssetImage('assets/images/hrd.png'),
                ),
              ),
            ),
          ),
          Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _GameButton(
                        normalImage: 'assets/images/menu.png',
                        pressedImage: 'assets/images/menu_on.png',
                        callback: () async {
                          var missions = (json.decode(
                                  await DefaultAssetBundle.of(context)
                                      .loadString(
                                          "assets/json/missions.json")) as List)
                              .map((e) => Mission.fromJson(e))
                              .toList();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  GameGallery(missions: missions)));
                        },
                      ),
                      _GameButton(
                          normalImage: 'assets/images/menu2.png',
                          pressedImage: 'assets/images/menu2_on.png',
                          callback: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Game(),
                                    settings: RouteSettings(
                                        name: 'game',
                                        arguments:
                                            GameArguments(newGame: false))))
                              }),
                      _GameButton(
                        normalImage: 'assets/images/menu3.png',
                        pressedImage: 'assets/images/menu3_on.png',
                        callback: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  contentPadding: const EdgeInsets.all(0),
                                  backgroundColor: Colors.transparent,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Image(
                                          image: AssetImage(
                                              'assets/images/settings.png')),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          border: Border.all(
                                            color: Colors.deepOrangeAccent,
                                            width: 3.0,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: const [
                                                Flexible(
                                                    flex: 3,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Image(
                                                          image: AssetImage(
                                                              'assets/images/music.png')),
                                                    )),
                                                Spacer(
                                                  flex: 8,
                                                ),
                                                Flexible(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: SwitchButton(
                                                        sharePreferenceKey: "music_on"),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: const [
                                                Flexible(
                                                    flex: 3,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Image(
                                                          image: AssetImage(
                                                              'assets/images/sfx.png')),
                                                    )),
                                                Spacer(
                                                  flex: 8,
                                                ),
                                                Flexible(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: SwitchButton(
                                                      sharePreferenceKey: "sfx_on",
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              });
                        },
                      ),
                    ]),
              )),
          const Spacer(
            flex: 1,
          )
        ],
      ),
    );
  }
}

class _GameButton extends StatefulWidget {
  final VoidCallback? callback;
  final String normalImage;
  final String pressedImage;

  const _GameButton(
      {required this.normalImage, required this.pressedImage, this.callback});

  @override
  State<StatefulWidget> createState() {
    return _GameButtonState();
  }
}

class _GameButtonState extends State<_GameButton> {
  bool normalState = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (TapDownDetails _) {
          setState(() {
            normalState = false;
          });
        },
        onTapUp: (TapUpDetails _) {
          setState(() {
            normalState = true;
          });
          var callback = widget.callback;
          if (callback != null) {
            callback();
          }
        },
        onTapCancel: () {
          setState(() {
            normalState = true;
          });
        },
        child: Stack(
          children: [
            Opacity(
              opacity: normalState ? 1 : 0,
              child: Image(
                image: AssetImage(widget.normalImage),
              ),
            ),
            Opacity(
              opacity: normalState ? 0 : 1,
              child: Image(
                image: AssetImage(widget.pressedImage),
              ),
            )
          ],
        ));
  }
}
