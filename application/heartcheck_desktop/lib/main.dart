import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'sidebar.dart';
import 'windows/support.dart';
import 'health_metrics.dart';
import 'windows/settings.dart';
import 'actions/greeting.dart';

void main() {
  runApp(const HeartCheckApp());
}

class HeartCheckApp extends StatelessWidget {
  const HeartCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartCheck',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        fontFamily: 'Inter',
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const DashboardScreen(),
    SettingsScreen(),
    const SupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: Row(
        children: [
          // Sidebar
          SidebarMenu(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          // Main Content
          Expanded(child: screens[selectedIndex]),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<HealthMetric> metrics = [
    HealthMetric(
      value: '120/80',
      label: 'Resting Blood Pressure',
      status: 'Normal',
      color: const Color(0xFF9DB8B3),
    ),
    HealthMetric(
      value: '140',
      label: 'Cholesterol',
      status: 'High',
      color: const Color(0xFF8B4A4A),
    ),
    HealthMetric(
      value: '150',
      label: 'Max Heart Rate',
      status: 'Elevated',
      color: const Color(0xFFB85A6E),
    ),
    HealthMetric(
      value: '+0.0',
      label: 'ST Depression',
      status: 'Normal',
      color: const Color(0xFF8B6A5A),
    ),
    HealthMetric(
      value: 'Normal',
      label: 'ST Slope',
      status: '',
      color: const Color(0xFFB8B3A8),
    ),
    HealthMetric(
      value: '85',
      label: 'Resting Heart Rate',
      status: 'Good',
      color: const Color(0xFFD4A574),
    ),
    HealthMetric(
      value: 'Normal',
      label: 'ECG Results',
      status: '',
      color: const Color(0xFF9DB8B3),
    ),
    HealthMetric(
      value: 'No',
      label: 'Exercise Induced Angina',
      status: '',
      color: const Color(0xFF5A6B7A),
    ),
    HealthMetric(
      value: '2',
      label: 'Major Vessels Count',
      status: '',
      color: const Color(0xFF9B7BA8),
    ),
    HealthMetric(
      value: '2',
      label: 'Thalassemia',
      status: '',
      color: const Color(0xFFD47A6E),
    ),
    HealthMetric(
      value: 'Asymptomatic',
      label: 'Chest Pain',
      status: '',
      color: const Color(0xFF4CAF50),
    ),
    HealthMetric(
      value: 'Normal',
      label: 'Thalassemia',
      status: '',
      color: const Color(0xFF2196F3),
    ),
    HealthMetric(
      value: '65%',
      label: 'Heart Health Score',
      status: '',
      color: const Color(0xFFFDD835),
    ),
    HealthMetric(
      value: '80',
      label: 'Max Exercise Heart Rate',
      status: 'Critical',
      color: const Color(0xFFE53935),
    ),
    HealthMetric(
      value: 'No',
      label: 'Arrhythmia Status',
      status: '',
      color: const Color(0xFF4A148C),
    ),
  ];

  // PDF exports
  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red700,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'HeartCheck Medical Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Patient: Alen',
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      DateTime.now().toString().split(' ')[0],
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              // Metrics Table
              pw.Text(
                'Health Metrics Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                cellStyle: const pw.TextStyle(fontSize: 11),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerLeft,
                },
                headers: ['Metric', 'Value', 'Status'],
                data: metrics.map((metric) {
                  return [
                    metric.label,
                    metric.value,
                    metric.status.isEmpty ? '-' : metric.status,
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 30),
              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'This report was generated by HeartCheck - For medical review only',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Show print/save dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF404040),
                    child: Icon(Icons.person, size: 35, color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${TimeBasedGreeting.getTimeBasedGreeting()}, Alen!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.only(left: 25, bottom: 20),
              child: ElevatedButton.icon(
                    onPressed: _exportToPdf,
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Export PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                ),
            // Dashboard Grid
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: metrics.length,
                    itemBuilder: (context, index) {
                      return HealthMetricCard(
                        metric: metrics[index],
                        onUpdate: (newValue) {
                          setState(() {
                            metrics[index] = metrics[index].copyWith(value: newValue);
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}