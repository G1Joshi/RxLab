import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'power_set.dart';

class PowerSetModule extends Module {
  @override
  String get id => 'power_set';

  @override
  String get label => 'Power Set';

  @override
  IconData get icon => Icons.list_alt_outlined;

  @override
  IconData get activeIcon => Icons.list_alt_rounded;

  @override
  Widget get screen => const PowerSetScreen();

  @override
  Future<void> init() async {
    final metadata = await DataLoader.loadList<PowerSetOperator>(
      path: AppAssets.powerSet.path,
      rootKey: AppAssets.powerSet.rootKey,
      fromJson: (json) => PowerSetOperator.fromJson(json),
    );

    PowerSets.init(metadata);
  }
}
