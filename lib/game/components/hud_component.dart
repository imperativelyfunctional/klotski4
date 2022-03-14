import 'dart:async' as async;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StepHudComponent extends TextComponent {
  final Color color;
  int currentValue;

  StepHudComponent({required this.color, required this.currentValue})
      : super(priority: 100) {
    textRenderer = TextPaint(
        style: TextStyle(shadows: const [
      Shadow(color: Colors.black87, offset: Offset(2, 2))
    ], fontSize: 20, color: color, fontWeight: FontWeight.bold));
  }

  @override
  void update(double dt) {
    super.update(dt);
    text = '步數 : $currentValue步';
  }
}

class TimeHudComponent extends TextComponent {
  final Color color;
  int currentValue;

  TimeHudComponent({required this.color, required this.currentValue})
      : super(priority: 100) {
    async.Timer.periodic(const Duration(seconds: 1), (_) {
      currentValue++;
    });
    textRenderer = TextPaint(
        style: TextStyle(shadows: const [
      Shadow(color: Colors.black87, offset: Offset(2, 2))
    ], fontSize: 20, color: color, fontWeight: FontWeight.bold));
  }

  @override
  void update(double dt) {
    super.update(dt);
    var seconds = currentValue % 60;
    var hours = currentValue / 60;
    text = '時間 :${hours.floor()}分鐘$seconds秒';
  }
}
