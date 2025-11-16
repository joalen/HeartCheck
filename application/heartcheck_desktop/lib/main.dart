import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/actions/greeting.dart';
import 'sidebar.dart';
import 'windows/support.dart';
import 'health_metrics.dart';
import 'windows/settings.dart';


void main() {
  runApp(const HeartCheckApp());
}

class HeartCheckApp extends StatelessWidget {
  const HeartCheckApp({Key? key}) : super(key: key);

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
    const SettingsScreen(),
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