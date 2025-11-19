import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/charts/bar_chart.dart';
import 'package:heartcheck_desktop/charts/radial_chart.dart';
import 'package:heartcheck_desktop/charts/line_chart.dart';

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

class ResultsScreen extends StatelessWidget {
  ResultsScreen({super.key});

  final List<MetricWithChart> metrics = [
    MetricWithChart(label: 'Blood Pressure', value: '120/80 bpm', chart: const CustomLineChart(
          minX: 0,
          maxX: 6,
          minY: 60,
          maxY: 100,
          spots: [
                  FlSpot(0, 85),
                  FlSpot(1, 88),
                  FlSpot(2, 82),
                  FlSpot(3, 90),
                  FlSpot(4, 87),
                  FlSpot(5, 84),
                  FlSpot(6, 86),
                ],
          lineColor: Colors.orangeAccent,
        )
      ),
    MetricWithChart(label: 'Cholesterol', value: '200 mg/dL', chart: const CustomBarChart(
        values: [210, 190, 195, 200], 
        barColor: Colors.blueAccent,
      )
    ),
      MetricWithChart(label: 'Max Heart Rate', value: '150 bpm', chart: const CustomLineChart(
        minX: 0,
        maxX: 6,
        minY: 60,
        maxY: 100,
        spots: [
                FlSpot(0, 85),
                FlSpot(1, 88),
                FlSpot(2, 82),
                FlSpot(3, 90),
                FlSpot(4, 87),
                FlSpot(5, 84),
                FlSpot(6, 86),
              ],
        lineColor: Colors.orangeAccent,
      )
    ),
    MetricWithChart(label: 'Brain Natriuetic Peptide', value: '80 pg/mL', chart: const CustomLineChart(
        minX: 0,
        maxX: 5,
        minY: 120,
        maxY: 160,
        spots: [
          FlSpot(0, 120),
          FlSpot(1, 130),
          FlSpot(2, 150),
          FlSpot(3, 160),
          FlSpot(4, 155),
          FlSpot(5, 148),
        ],
        lineColor: Colors.redAccent,
      )
    ),
    MetricWithChart(label: 'Ejection Fraction', value: '65%', chart: CustomRadialChart(
        values: [65, 35],
        colors: [Colors.yellow.shade700, Colors.grey.shade300],
      )
    ),
    MetricWithChart(label: 'ST Depression', value: '+0.0 mm', chart: const CustomLineChart(
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 10,
        spots: [
          FlSpot(0, 1),
          FlSpot(1, 0),
          FlSpot(2, 2),
          FlSpot(3, 1),
          FlSpot(5, 0),
        ],
        lineColor: Color.fromARGB(255, 8, 156, 156),
      )
    ),
    MetricWithChart(label: 'ST Slope', value: 'Normal', chart: const CustomLineChart(
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 10,
        spots: [
          FlSpot(0, 1),
          FlSpot(1, 3),
          FlSpot(2, 2),
        ],
        lineColor: Colors.deepPurpleAccent,
      )
    ),
    MetricWithChart(label: 'Resting ECG', value: 'Normal', chart: CustomRadialChart(
        values: [20, 80],
        colors: [Colors.pink, Colors.greenAccent.shade200],
      )
    ),
    MetricWithChart(label: 'Exercise Induced Angina', value: 'No', chart: CustomRadialChart(
        values: [15, 85],
        colors: [Colors.brown, Colors.blueGrey.shade200],
      )
    ),
    MetricWithChart(label: 'Major Vessel Count', value: '2', chart: CustomBarChart(
        values: [210, 195, 200], 
        barColor: Colors.lightGreenAccent,
      )
    ),
    MetricWithChart(label: 'Thalassemia', value: 'Normal', chart: CustomBarChart(
        values: [210, 195, 100, 200], 
        barColor: Colors.green.shade300,
      )
    ),
    MetricWithChart(label: 'Chest Pain Type', value: 'Asymptotic', chart: CustomBarChart(
        values: [1, 3, 4, 2], 
        barColor: Colors.purple,
      )
    ), 
    MetricWithChart(label: 'Angiographic Status', value: 'No', chart: CustomRadialChart(
        values: [15, 85],
        colors: [Colors.red, Colors.grey.shade100],
      )
    ),
    MetricWithChart(label: 'C-Reactive Protein', value: '2 mg/L', chart: const CustomLineChart(
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 10,
        spots: [
          FlSpot(0, 1),
          FlSpot(1, 3),
          FlSpot(2, 2),
        ],
        lineColor: Colors.teal,
      )
    ),
    MetricWithChart(label: 'Fasting Blood Sugar', value: '85 mg/dl', chart: CustomLineChart(
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 250,
        spots: [
          FlSpot(0, 100),
          FlSpot(1, 80),
          FlSpot(2, 90),
          FlSpot(3, 90),
          FlSpot(4, 95),
        ],
        lineColor: Colors.lime,
      )
    ), 
  ];

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withOpacity(0.05),
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