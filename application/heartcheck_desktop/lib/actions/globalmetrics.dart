import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/health_metrics.dart';

class GlobalMetrics extends ChangeNotifier {
  static final GlobalMetrics _instance = GlobalMetrics._internal();
  factory GlobalMetrics() => _instance;
  GlobalMetrics._internal();

  final List<HealthMetric> _metrics = [];

  List<HealthMetric> get metrics => _metrics;

  void setMetrics(List<HealthMetric> newMetrics) {
    _metrics
      ..clear()
      ..addAll(newMetrics);
    notifyListeners();
  }

  void updateMetric(int index, HealthMetric metric) {
    _metrics[index] = metric;
    notifyListeners();
  }
}
