import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

enum _BgProps { color1, color2 }

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<_BgProps>()
      ..add(
        _BgProps.color1,
        Color(0xffFFB84E).tweenTo(Colors.lightBlue.shade900),
      )
      ..add(
        _BgProps.color2,
        Color(0xffA83279).tweenTo(Colors.blue.shade600),
      );

    return MirrorAnimation<MultiTweenValues<_BgProps>>(
      tween: tween,
      duration: 3.seconds,
      builder: (context, child, value) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [value.get(_BgProps.color1), value.get(_BgProps.color2)],
            ),
          ),
        );
      },
    );
  }
}
