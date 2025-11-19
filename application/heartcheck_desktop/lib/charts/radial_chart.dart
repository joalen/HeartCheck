import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomRadialChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double radius;
  final double centerSpaceRadius;
  final bool showPercentage;

  const CustomRadialChart({
    super.key,
    required this.values,
    required this.colors,
    this.radius = 50,
    this.centerSpaceRadius = 25,
    this.showPercentage = true,
  }) : assert(values.length == colors.length, 'Values and colors must match in length');

  @override
  Widget build(BuildContext context) {
    final total = values.fold(0.0, (sum, v) => sum + v);

    return PieChart(
      PieChartData(
        sections: List.generate(values.length, (index) {
          return PieChartSectionData(
            value: values[index],
            color: colors[index],
            radius: radius,
            title: showPercentage
                ? '${((values[index] / total) * 100).toStringAsFixed(0)}%'
                : '',
            titleStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        }),
        centerSpaceRadius: centerSpaceRadius,
      ),
    );
  }
}