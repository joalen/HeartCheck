import 'package:flutter/material.dart';
import 'package:heartcheck_desktop/actions/editable_setting_item.dart';

String getLanguage(BuildContext context) {
  return Localizations.localeOf(context).languageCode;
}


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                      initialValue: 'alen@heartcheck.com',
                      onUpdate: (value) {
                        // TODO: send API call
                      },
                    ),
                    EditableSettingItem(
                      label: 'Password',
                      initialValue: '••••••••',
                      onUpdate: (value) {
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingSection('Region Settings', [
                    buildDropdownSettingItem('Language', selectedLanguageNotifier),
                    _buildSettingItem('Time Format', '12h/24h/YYYY'),
                    _buildSettingItem('Date Format', 'MM/DD/YYYY'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingSection('Other', [
                    _buildSettingItem('Update App', 'v1.0.0'),
                    _buildSettingItem('Changelog', 'View history'),
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

  Widget _buildSettingItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}