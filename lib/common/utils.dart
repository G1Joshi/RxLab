import 'package:flutter/material.dart';

import 'theme.dart';

class Utils {
  static IconData getIcon(
    String? name, {
    IconData fallback = Icons.help_outline,
  }) {
    if (name == null || name.isEmpty) return fallback;

    return switch (name.toLowerCase()) {
      'observable' || 'stream' || 'waves' => Icons.waves,
      'observer' || 'visibility' => Icons.visibility_outlined,
      'subscription' || 'link' => Icons.link,
      'subject' || 'swap_horiz' => Icons.swap_horiz,
      'hot' || 'whatshot' => Icons.whatshot,
      'cold' || 'ac_unit' => Icons.ac_unit,
      'scheduler' || 'schedule' => Icons.schedule,
      'backpressure' || 'compress' => Icons.compress,
      'operator' || 'build' || 'construction' => Icons.construction,
      'map' || 'transform' => Icons.transform,
      'filter' || 'filter_alt' || 'filter_list' => Icons.filter_alt_outlined,
      'flatmap' || 'layers' => Icons.layers_outlined,
      'switch' || 'switch_access_shortcut' => Icons.switch_access_shortcut,
      'merge' || 'call_merge' || 'merge_type' => Icons.call_merge,
      'zip' || 'unfold_less' => Icons.unfold_less,
      'combine' || 'grain' => Icons.grain,
      'error' || 'healing' || 'bug_report' => Icons.bug_report_outlined,
      'retry' || 'refresh' => Icons.refresh,
      'buffer' || 'inventory' => Icons.inventory_2_outlined,
      'window' || 'grid_view' => Icons.grid_view,
      'debounce' || 'timer' || 'timer_3' => Icons.timer_3_outlined,
      'throttle' || 'speed' => Icons.speed,
      'sample' || 'biotech' => Icons.biotech_outlined,
      'audit' || 'fact_check' => Icons.fact_check_outlined,
      'take' || 'content_cut' => Icons.content_cut,
      'skip' || 'skip_next' => Icons.skip_next_outlined,
      'distinct' || 'auto_awesome' => Icons.auto_awesome_outlined,
      'memory' || 'storage' => Icons.memory,
      'sync' || 'sync_alt' => Icons.sync_alt,
      'check_circle' || 'offline_pin' => Icons.offline_pin_outlined,
      'view_list' || 'list' => Icons.view_list,
      'cached' || 'history' => Icons.history,
      'flash_on' || 'bolt' => Icons.bolt,
      'cloud_download' || 'download' => Icons.cloud_download_outlined,
      'pan_tool' || 'back_hand' || 'touch_app' => Icons.touch_app_outlined,
      'undo' || 'history_edu' => Icons.history_edu,
      'quiz' || 'help' => Icons.help_outline,
      'school' || 'menu_book' => Icons.menu_book,
      'warning' || 'report_problem' => Icons.report_problem_outlined,
      'info' || 'info_outline' => Icons.info_outline,
      'settings' || 'tune' => Icons.tune,
      'category' || 'folder' => Icons.folder_outlined,
      'behavior' || 'psychology' => Icons.psychology_outlined,
      'multicast' || 'hub' => Icons.hub_outlined,
      'connectable' || 'power' => Icons.power_outlined,
      'composition' || 'account_tree' => Icons.account_tree_outlined,
      'lifecycle' || 'autorenew' => Icons.autorenew,
      'search' => Icons.search,
      'pattern' || 'texture' => Icons.texture,
      'creation' || 'add_circle' => Icons.add_circle_outline,
      'conditional' || 'alt_route' => Icons.alt_route,
      'aggregate' || 'functions' => Icons.functions,
      'conversion' || 'transform' => Icons.transform,
      'timer_outline' => Icons.timer_outlined,
      'play_arrow' => Icons.play_arrow_outlined,
      'pause' => Icons.pause_circle_outline,
      'stop' => Icons.stop_circle,
      'lightbulb' => Icons.lightbulb_outline,
      'star' => Icons.star_outline,
      'hourglass' || 'hourglass_empty' => Icons.hourglass_empty,
      'restaurant' || 'restaurant_menu' => Icons.restaurant_menu,
      _ => fallback,
    };
  }

  static IconData getCategoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'creation' => getIcon('creation'),
      'transformation' => getIcon('transform'),
      'filtering' => getIcon('filter'),
      'combination' => getIcon('merge'),
      'error handling' || 'error' => getIcon('error'),
      'utility' => getIcon('settings'),
      'conditional' => getIcon('conditional'),
      'aggregate' => getIcon('functions'),
      'connectable' => getIcon('power'),
      'conversion' => getIcon('sync'),

      'core' || 'basics' => getIcon('hub'),
      'subjects' || 'multicast' => getIcon('swap_horiz'),
      'concepts' || 'theory' => getIcon('school'),
      'patterns' || 'recipes' => getIcon('pattern'),
      'problems' || 'anti-patterns' || 'anti_patterns' => getIcon('warning'),
      'practical' => getIcon('restaurant'),
      'predict_output' => getIcon('psychology'),
      'find_bug' => getIcon('error'),
      _ => getIcon('help'),
    };
  }

  static Color getColor(String? name, {Color fallback = Colors.grey}) {
    if (name == null || name.isEmpty) return fallback;

    if (name.startsWith('#')) {
      try {
        final hex = name.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      } catch (_) {}
    }

    return switch (name.toLowerCase()) {
      'blue' || 'primary' => AppTheme.primary,
      'purple' || 'secondary' => AppTheme.secondary,
      'cyan' || 'accent' => AppTheme.accent,
      'green' || 'success' => AppTheme.success,
      'orange' || 'warning' => AppTheme.warning,
      'red' || 'error' => AppTheme.error,
      'bluegrey' || 'blue_grey' || 'muted' => AppTheme.textMuted,
      'teal' => Colors.teal,
      'indigo' => Colors.indigo,
      'amber' => Colors.amber,
      'brown' => Colors.brown,
      'deeporange' || 'deep_orange' => Colors.deepOrange,
      'deeppurple' || 'deep_purple' => Colors.deepPurple,
      'pink' => Colors.pink,
      'lime' => Colors.lime,
      'yellow' => Colors.yellow,
      'grey' || 'gray' => Colors.grey,
      'black' => Colors.black,
      'white' => Colors.white,
      _ => fallback,
    };
  }

  static Color getCategoryColor(String category) {
    return switch (category.toLowerCase()) {
      'creation' => AppTheme.categoryCreation,
      'transformation' => AppTheme.categoryTransformation,
      'combination' => AppTheme.categoryCombination,
      'filtering' => AppTheme.categoryFiltering,
      'error handling' || 'error' => AppTheme.categoryError,
      'utility' => AppTheme.categoryUtility,
      'conditional' => Colors.indigo,
      'aggregate' => Colors.purple,
      'connectable' => Colors.teal,
      'conversion' => Colors.amber,

      'core' || 'basics' => getColor('blue'),
      'subjects' || 'advanced' || 'operators' => getColor('purple'),
      'concepts' || 'theory' => getColor('teal'),
      'patterns' || 'recipes' => getColor('green'),
      'problems' || 'anti-patterns' || 'anti_patterns' => getColor('red'),
      'practical' => getColor('orange'),
      'easy' => getColor('green'),
      'medium' => getColor('orange'),
      'hard' => getColor('red'),
      _ => getColor('grey'),
    };
  }
}
