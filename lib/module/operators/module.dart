import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'operators.dart';

class OperatorsModule extends Module {
  @override
  String get id => 'operators';

  @override
  String get label => 'Operators';

  @override
  IconData get icon => Icons.dashboard_outlined;

  @override
  IconData get activeIcon => Icons.dashboard_rounded;

  @override
  Widget get screen => const OperatorsScreen();

  @override
  bool get isTopLevel => true;

  @override
  int get priority => 100;

  @override
  Color get color => Colors.blue;

  @override
  Future<void> init() async {
    final metadata = await DataLoader.loadList<OperatorDefinition>(
      path: AppAssets.operators.path,
      rootKey: AppAssets.operators.rootKey,
      fromJson: (json) => OperatorDefinition.fromJson(json),
    );

    Operators.init(metadata);
  }
}
