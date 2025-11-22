import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/actions/dbactions.dart';
import 'package:heartcheck_desktop/actions/exports.dart';
import 'package:heartcheck_desktop/actions/globalmetrics.dart';
import 'package:heartcheck_desktop/actions/profilepicture.dart';
import 'package:heartcheck_desktop/platform/update_agent_stub.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'sidebar.dart';
import 'windows/support.dart';
import 'windows/results.dart';
import 'health_metrics.dart';
import 'windows/settings.dart';
import 'actions/greeting.dart';
import 'windows/credits.dart';
export 'platform/update_agent_stub.dart' if (dart.library.ffi) 'platform/windows/windows_updater.dart';
import 'windows/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
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
  File? _imageFile;
  String? _profileImageUrl;

  late List<HealthMetric> metrics = [];

  Future<void> _pickAndCropImage() async {
    // Pick image
    final XFile? pickedFile = await pickImage();

    if (pickedFile != null) {
      // Crop the image
      final croppedImage = await cropImage(pickedFile.path);
      
      if (croppedImage != null) {
        setState(() {
          _imageFile = croppedImage;
        });
      
        await uploadAndSaveProfileImage(croppedImage);
        await _loadProfileImage();
      }
    }
  }

  Future<void> _loadProfileImage() async {
    final uid = CurrentUser.instance!.firebaseUid;
    
    final data = await Supabase.instance.client
        .from('users')
        .select('profile_url')
        .eq('firebaseuid', uid)
        .maybeSingle();

    if (mounted) {
      setState(() {
        _profileImageUrl = data?['profile_url'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      userFuture = fetchUser(uid);
      
      userFuture.then((user) async {
        HealthMetricWidgetFactory hmwf = HealthMetricWidgetFactory();
        metrics = await hmwf.createHealthWidgets();
        metrics = await populateHealthMetricsFromDB(uid, metrics);
        GlobalMetrics().setMetrics(metrics);
        
        if (user != null) {
          setState(() {
            greetingName = '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}';
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
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickAndCropImage, 
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFF404040),
                              backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null),
                              child: (_imageFile == null && _profileImageUrl == null)
                                  ? const Icon(Icons.person, size: 35, color: Colors.white70)
                                  : null,
                            )
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.orange,
                              child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                            ),
                          )
                        ],
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
                      await exportToPdf(await metrics);
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
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: GlobalMetrics().metrics.length,
                itemBuilder: (context, index) {
                  final metric = GlobalMetrics().metrics[index];
                  return HealthMetricCard(
                    metric: metric,
                    onUpdate: (newValue) {
                      setState(() {
                        GlobalMetrics().updateMetric(index, metric.copyWith(value: newValue));
                      });
                    },
                  );
                },
              )
            )
          ],
        ),
      ),
    );
  }
}