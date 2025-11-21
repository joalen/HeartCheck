import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/actions/apiservices.dart';
import 'package:heartcheck_desktop/actions/dbactions.dart';
import 'package:heartcheck_desktop/actions/interactive_components.dart';
import 'package:heartcheck_desktop/platform/windows/windows_updater.dart';
import 'package:heartcheck_desktop/windows/login.dart';
import 'package:intl/intl.dart';
import 'package:version/version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

Future<String> retrieveAppVersion() async
{ 
  return (await PackageInfo.fromPlatform()).version;
}

Future<String> loadChangelog() async {
  return await rootBundle.loadString('assets/changelog.md');
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsScreen>
{
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _version = "Loading...";

  @override
  void initState()
  { 
    super.initState(); 
    _loadVersion();
  }

  Future<void> _loadVersion() async 
  { 
    final version = await retrieveAppVersion(); 
    setState(() { 
      _version = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String> selectedLanguageNotifier = ValueNotifier(Localizations.localeOf(context).toString());

    return Container(
      color: const Color(0xFF2A2A2A),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingSection('Account Settings', [
                    EditableSettingItem(
                      label: 'Username/Email',
                      initialValue: CurrentUser.instance?.email ?? '',
                      onUpdate: (value) async {
                        try 
                        { 
                          final idToken = CurrentUser.instance?.jwt;
                          final uid = CurrentUser.instance?.firebaseUid;

                          if (idToken != null && uid != null)
                          { 
                            await FirebaseRestAuth.updateFirebaseEmail(idToken, value);
                            await updateUserEmail(uid, value);
                            CurrentUser.instance?.email = value;

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email updated successfully!')));
                          }
                        } catch (e)
                        { 
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update email: $e')));
                        }
                      },
                    ),
                    EditableSettingItem(
                      label: 'Password',
                      initialValue: '••••••••', // for security reasons, no password is shown therefore if the user forgot their password, they must go through forgot password flow or change password flow!
                      onUpdate: (value) async {
                        try { 
                          final idToken = CurrentUser.instance?.jwt;

                          if (idToken != null)
                          { 
                            await FirebaseRestAuth.updateFirebasePassword(idToken, value);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
                          }
                        } catch (e)
                        { 
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password: $e')));
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingSection('Region Settings', [
                    buildDropdownSettingItem('Language', selectedLanguageNotifier),
                    buildDateTimePickerItem( 
                      "Date",
                       DateFormat.yMd().format(_selectedDate),
                       () async { 
                        final picked = await showDatePicker(
                          context: context, 
                          firstDate: DateTime(1970), 
                          lastDate: DateTime(2100)
                          );

                          if (!mounted) return;

                          if (picked != null) 
                          { 
                            setState(() => _selectedDate = picked);
                          }
                       }
                    ),
                    buildDateTimePickerItem( 
                      "Time",
                       DateFormat.yMd().format(_selectedDate),
                       () async { 
                        final picked = await showTimePicker(
                          context: context, 
                          initialTime: _selectedTime,
                          );

                          if (!mounted) return;

                          if (picked != null) 
                          { 
                            setState(() => _selectedTime = picked);
                          }
                       }
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingSection('Other', [
                    // Update functionality
                    buildTapItem(
                      "Version", 
                      _version,
                      () async 
                      {
                        final latest = await fetchLatestGitHubTag();
                        if (!mounted) return;

                        if (latest == null) 
                        { 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Unable to check for updates"))
                          );

                          return;
                        }
                                                
                        if (Version.parse(latest) > Version.parse(_version))
                        { 
                          showDialog(
                            context: context, 
                            builder: (_) => AlertDialog(
                                title: const Text("Update available"),
                                content: Text("A new version ($latest) is available to install! Want to install?"),
                                actions: [
                                  TextButton(
                                    onPressed: 
                                      () {
                                        Navigator.pop(context);

                                        if (Platform.isWindows) {
                                          WindowsUpdater.checkForUpdates();
                                        }
                                      },
                                    child: const Text("Yes")
                                  ),
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("No"))
                                ],
                              )
                            );
                        } else { 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("You're on the latest version!")),
                          );
                        }

                      }
                      ),
                      buildTapItem(
                        'Changelog',
                        'View history',
                         () async {
                          final changelog = await loadChangelog();
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Changelog"),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: Markdown(data: changelog),
                              ),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                            ),
                          );
                        },
                      )
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }
}