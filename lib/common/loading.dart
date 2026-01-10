import 'package:flutter/material.dart';

mixin DataLoadingMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadData(Future<void> Function() loader) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await loader();
    } catch (e) {
      if (mounted) {
        setState(() => errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
