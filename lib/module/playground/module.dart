import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'playground.dart';

class PlaygroundModule extends Module {
  @override
  String get id => 'playground';

  @override
  String get label => 'Playground';

  @override
  IconData get icon => Icons.science_outlined;

  @override
  IconData get activeIcon => Icons.science_rounded;

  @override
  Widget get screen => const PlaygroundScreen();

  @override
  bool get isTopLevel => true;

  @override
  int get priority => 80;

  @override
  Color get color => Colors.green;
}
