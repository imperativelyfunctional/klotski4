import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchButton extends StatefulWidget {
  final String sharePreferenceKey;

  const SwitchButton({Key? key, required this.sharePreferenceKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SwitchButtonState();
}

class SwitchButtonState extends State<SwitchButton> {
  late bool on = true;

  SwitchButtonState();

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  _checkState() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var state = pref.getBool(widget.sharePreferenceKey);
    setState(() {
      on = state ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: on
          ? const Image(image: AssetImage('assets/images/on.png'))
          : const Image(image: AssetImage('assets/images/off.png')),
      onTap: () async {
        final SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool(widget.sharePreferenceKey, !on);
        setState(() {
          on = !on;
        });
      },
    );
  }
}
