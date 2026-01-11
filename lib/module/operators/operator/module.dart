import 'package:flutter/material.dart';

import '../../../common/common.dart';
import 'operator.dart';

class OperatorDetailsModule extends Module {
  final OperatorDefinition operator_;

  OperatorDetailsModule({required this.operator_});

  @override
  String get id => 'operator_details_${operator_.name}';

  @override
  String get label => operator_.name;

  @override
  IconData get icon => Icons.info_outline;

  @override
  IconData get activeIcon => Icons.info;

  @override
  Widget get screen => OperatorDetailScreen(operator_: operator_);

  @override
  Color get color => Colors.blue;
}
