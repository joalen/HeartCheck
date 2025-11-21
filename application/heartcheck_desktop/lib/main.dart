import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/actions/dbactions.dart';
import 'package:heartcheck_desktop/actions/exports.dart';
import 'package:heartcheck_desktop/platform/update_agent_stub.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'sidebar.dart';
import 'windows/support.dart';
import 'windows/results.dart';
import 'health_metrics.dart';
import 'windows/settings.dart';
import 'actions/greeting.dart';
import 'windows/credits.dart';
export 'platform/update_agent_stub.dart' if (dart.library.ffi) 'platform/windows/windows_updater.dart';
import 'windows/login.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  if (Platform.isWindows) {
    WindowsUpdater.checkForUpdates();
  }

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
      home: const LoginScreen(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const DashboardScreen(),
    ResultsScreen(),
    SettingsScreen(),
    const SupportScreen(),
    CreditsScreen()
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
  const DashboardScreen({super.key}) : super();

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>?> userFuture;
  String greetingName = 'User';

  final List<HealthMetric> metrics = [
    HealthMetric(
      value: '120/80',
      unit: 'mmHg',
      label: 'Resting Blood Pressure',
      color: const Color(0xFF9DB8B3),
    ),
    HealthMetric(
      value: '140',
      unit: 'mm/dl',
      label: 'Cholesterol',
      color: const Color(0xFF8B4A4A),
    ),
    HealthMetric(
      value: '150',
      unit: 'bpm',
      label: 'Max Heart Rate',
      color: const Color(0xFFB85A6E),
    ),
    HealthMetric(
      value: '+0.0',
      unit: 'mm',
      label: 'ST Depression',
      color: const Color(0xFF8B6A5A),
    ),
    HealthMetric(
      value: 'Normal',
      unit: '',
      label: 'ST Slope',
      color: const Color(0xFFB8B3A8),
    ),
    HealthMetric(
      value: '85',
      unit: 'mg/dl',
      label: 'Fasting Blood Sugar',
      color: const Color(0xFFD4A574),
    ),
    HealthMetric(
      value: 'Normal',
      unit: '',
      label: 'Resting ECG',
      color: const Color(0xFF9DB8B3),
    ),
    HealthMetric(
      value: 'No',
      unit: '',
      label: 'Exercise Induced Angina',
      color: const Color(0xFF5A6B7A),
    ),
    HealthMetric(
      value: '2',
      unit: '',
      label: 'Major Vessels Count',
      color: const Color(0xFF9B7BA8),
    ),
    HealthMetric(
      value: '2',
      unit: 'mg/L',
      label: 'C-Reactive Protein',
      color: const Color(0xFFD47A6E),
    ),
    HealthMetric(
      value: 'Asymptomatic',
      unit: '',
      label: 'Chest Pain',
      color: const Color(0xFF4CAF50),
    ),
    HealthMetric(
      value: 'Normal',
      unit: '',
      label: 'Thalassemia',
      color: const Color(0xFF2196F3),
    ),
    HealthMetric(
      value: '65%',
      unit: '',
      label: 'Ejection Fraction',
      color: const Color(0xFFFDD835),
    ),
    HealthMetric(
      value: '80',
      unit: 'pg/mL',
      label: 'Brain Natrieretic Peptide',
      color: const Color(0xFFE53935),
    ),
    HealthMetric(
      value: 'No',
      unit: '',
      label: 'Angiographic Status',
      color: const Color(0xFF4A148C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      userFuture = fetchUser(uid);
      userFuture.then((user) {
      if (user != null) {
        setState(() {
          greetingName = '${user['firstname']} ${user['lastname']}';
        });
      }
    });

    } else {
      // usually this means that PostgreSQL DB was not able to find the entry that matched with Firebase!
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
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
              child: FutureBuilder<Map<String, dynamic>?>(
                future: userFuture,
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF404040),
                        child: Icon(Icons.person, size: 35, color: Colors.white70),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${TimeBasedGreeting.getTimeBasedGreeting()}, $greetingName!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(padding: const EdgeInsets.only(left: 25, bottom: 20),
              child: ElevatedButton.icon(
                    onPressed: () async {
                      await exportToPdf(metrics);
                    },
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: GridView.builder(
                  shrinkWrap: true,  // Makes the grid fit the available space
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
                )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}