import 'package:flutter/material.dart';

abstract class Module {
  String get id;

  String get label;

  IconData get icon;

  IconData get activeIcon;

  Widget get screen;

  Color get color => Colors.blue;

  bool get isTopLevel => false;

  bool get isLearningTool => false;

  bool get isLabTool => false;

  int get priority => 0;

  Future<void> init() async {}
}

class ModuleRegistry {
  static final List<Module> _modules = [];

  static void register(Module module) {
    _modules.add(module);
  }

  static List<Module> get all => List.unmodifiable(_modules);

  static List<Module> get topLevelModules {
    final modules = _modules.where((m) => m.isTopLevel).toList();
    modules.sort((a, b) => b.priority.compareTo(a.priority));
    return modules;
  }

  static List<Module> get learningTools {
    final tools = _modules.where((m) => m.isLearningTool).toList();
    tools.sort((a, b) => b.priority.compareTo(a.priority));
    return tools;
  }

  static List<Module> get labTools {
    final tools = _modules.where((m) => m.isLabTool).toList();
    tools.sort((a, b) => b.priority.compareTo(a.priority));
    return tools;
  }

  static Module? find(String id) {
    try {
      return _modules.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
