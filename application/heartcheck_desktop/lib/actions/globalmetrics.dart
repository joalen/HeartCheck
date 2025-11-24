import 'dart:async';

import 'package:flutter/material.dart';
import 'package:HeartCheck/actions/dbactions.dart';
import 'package:HeartCheck/health_metrics.dart';
import 'package:HeartCheck/windows/auth/login.dart';

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
      if (metric.label == "Angiographic Status" && metric.value == "Usage reached")
      { 
        return;
      }
      updateTimeSeriesDB(CurrentUser.instance!.firebaseUid, metric.label, {'metric': metric.value});
    });
  }
}
