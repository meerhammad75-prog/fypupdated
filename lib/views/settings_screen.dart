import 'package:flutter/material.dart';
import 'package:news_app/theme/energy_theme.dart';
import 'package:news_app/views/widgets/energy_glow_card.dart';
import 'package:news_app/views/widgets/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<TextEditingController> _deviceControllers = [
    TextEditingController(text: 'Living Room Lights'),
    TextEditingController(text: 'Studio AC'),
    TextEditingController(text: 'EV Charger'),
  ];

  final TextEditingController _ssidController = TextEditingController(text: 'SmartHome_2.4G');
  final TextEditingController _wifiPasswordController = TextEditingController(text: 'energy@2024');

  String _selectedTimezone = 'GMT+05:00 · Asia/Karachi';
  bool _darkMode = true;
  bool _autoUpdate = true;

  @override
  void dispose() {
    for (final controller in _deviceControllers) {
      controller.dispose();
    }
    _ssidController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timezones = [
      'GMT-08:00 · Pacific Time',
      'GMT-05:00 · Eastern Time',
      'GMT+00:00 · London',
      'GMT+01:00 · Berlin',
      'GMT+05:00 · Asia/Karachi',
      'GMT+08:00 · Singapore',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const EnergySectionHeader(
            title: 'Devices',
            subtitle: 'Rename zones or smart plugs for better recognition',
          ),
          EnergyGlowCard(
            child: Column(
              children: [
                ..._deviceControllers.map(
                  (controller) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Device name',
                        prefixIcon: Icon(Icons.sensors),
                      ),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _deviceControllers.add(TextEditingController(text: 'New Device'));
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EnergyTheme.electricBlue,
                    side: BorderSide(color: EnergyTheme.electricBlue.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add device'),
                ),
              ],
            ),
          ),
          const EnergySectionHeader(
            title: 'Experience',
            subtitle: 'Personalize theme and firmware preferences',
          ),
          EnergyGlowCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark theme'),
                  subtitle: const Text('Reduce glare with AMOLED friendly palette'),
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
                const Divider(height: 0, color: Colors.white12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto update devices'),
                  subtitle: const Text('Apply firmware overnight when idle'),
                  value: _autoUpdate,
                  onChanged: (value) => setState(() => _autoUpdate = value),
                ),
              ],
            ),
          ),
          const EnergySectionHeader(
            title: 'Scheduling timezone',
            subtitle: 'Align automation blocks with your preferred city',
          ),
          EnergyGlowCard(
            child: DropdownButtonFormField<String>(
              value: _selectedTimezone,
              dropdownColor: EnergyTheme.panel,
              borderRadius: BorderRadius.circular(16),
              items: timezones
                  .map((tz) => DropdownMenuItem(value: tz, child: Text(tz)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTimezone = value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Timezone',
                prefixIcon: Icon(Icons.public),
              ),
            ),
          ),
          const EnergySectionHeader(
            title: 'Wi-Fi credentials',
            subtitle: 'Push new SSID/password to your devices',
          ),
          EnergyGlowCard(
            child: Column(
              children: [
                TextField(
                  controller: _ssidController,
                  decoration: const InputDecoration(
                    labelText: 'Network name (SSID)',
                    prefixIcon: Icon(Icons.wifi),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _wifiPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Wi-Fi password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Update credentials'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          EnergyGlowCard(
            gradient: LinearGradient(
              colors: [
                Colors.redAccent.withOpacity(0.15),
                EnergyTheme.panel,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




