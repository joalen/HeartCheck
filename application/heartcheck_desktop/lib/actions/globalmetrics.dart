import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/actions/dbactions.dart';
import 'package:heartcheck_desktop/health_metrics.dart';
import 'package:heartcheck_desktop/windows/auth/login.dart';

class GlobalMetrics extends ChangeNotifier {
  Timer? _debounce;
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

    _debounce?.cancel(); 
    _debounce = Timer(const Duration(milliseconds: 500), ()
    { 
      updateTimeSeriesDB(CurrentUser.instance!.firebaseUid, metric.label, {'metric': metric.value});
    });
  }
}
