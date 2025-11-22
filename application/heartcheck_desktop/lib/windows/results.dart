import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/actions/globalmetrics.dart';
import 'package:heartcheck_desktop/charts/bar_chart.dart';
import 'package:heartcheck_desktop/charts/radial_chart.dart';
import 'package:heartcheck_desktop/charts/line_chart.dart';
import 'package:heartcheck_desktop/health_metrics.dart';

class MetricWithChart {
  final String label;
  final String value;
  final Widget chart;

  MetricWithChart({
    required this.label,
    required this.value,
    required this.chart,
  });
}

MetricWithChart healthMetricIntoChart(HealthMetric metric)
{ 
  Widget chart = const SizedBox(); 
  String fullMetric = metric.label.toLowerCase();

  if (metric.trend.isEmpty)
  { 
    chart = const SizedBox.shrink();
  } else if (fullMetric.contains('vessel') || fullMetric.contains('cholesterol') || fullMetric.contains('thal') || fullMetric.contains('chest pain')) 
  { 
    chart = CustomBarChart(
      values: metric.trend.isNotEmpty ? metric.trend : [double.tryParse(metric.value) ?? 0],
      barColor: metric.color,
    );
  } else if (fullMetric.contains('ejection fraction') || fullMetric.contains('ecg') || fullMetric.contains('angina'))
  {
    final val = double.tryParse(metric.value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    chart = CustomRadialChart(
      values: [val, 100 - val],
      colors: [metric.color, Colors.grey.shade300]
    );
  }
  else if (fullMetric.contains('blood pressure') || fullMetric.contains('heart rate') || fullMetric.contains('glucose') || metric.trend.length > 1)
  { 
    final spots = List.generate(
      metric.trend.length, 
      (i) => FlSpot(i.toDouble(), metric.trend[i]),
    );

    final minY = metric.trend.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = metric.trend.reduce((a, b) => a > b ? a : b) * 1.1;

    chart = CustomLineChart(
      minX: 0,
      maxX: (metric.trend.length - 1).toDouble(), 
      minY: minY,
      maxY: maxY,
      spots: spots, 
      lineColor: metric.color
    );
  }

  return MetricWithChart(label: metric.label, value: metric.value, chart: chart);
}

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<MetricWithChart> metrics = [];
    List<HealthMetric> metricsFromDashboard = GlobalMetrics().metrics;
    metrics = metricsFromDashboard.map((m) => healthMetricIntoChart(m)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Results', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 2x2 squares
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // perfect squares
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return MetricCard(metric: metric);
          },
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final MetricWithChart metric;

  const MetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: metric.chart),
          const SizedBox(height: 8),
          Text(
            metric.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            metric.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}