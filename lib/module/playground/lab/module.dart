import 'package:flutter/material.dart';

import '../../../common/common.dart';
import 'lab.dart';

class LabModule extends Module {
  @override
  String get id => 'lab';

  @override
  String get label => 'Lab';

  @override
  IconData get icon => Icons.science_outlined;

  @override
  IconData get activeIcon => Icons.science;

  @override
  Widget get screen => const LabScreen();

  @override
  bool get isLabTool => true;

  @override
  int get priority => 70;
}
