import 'package:flutter/material.dart';
import 'package:news_app/theme/energy_theme.dart';
import 'package:news_app/views/widgets/energy_glow_card.dart';
import 'package:news_app/views/widgets/section_header.dart';

class AlertsNotificationsScreen extends StatefulWidget {
  const AlertsNotificationsScreen({super.key});

  static const routeName = '/alerts-notifications';

  @override
  State<AlertsNotificationsScreen> createState() => _AlertsNotificationsScreenState();
}

class _AlertsNotificationsScreenState extends State<AlertsNotificationsScreen> {
  int _selectedFilter = 0;
  bool _muteCritical = false;

  final List<Map<String, dynamic>> _highUsageAlerts = [
    {
      'device': 'HVAC Controller',
      'value': '5.6 kW',
      'status': 'Critical spike detected at 09:32 AM',
      'trend': '+34%',
      'color': Colors.redAccent,
    },
    {
      'device': 'Water Heater',
      'value': '3.1 kW',
      'status': 'Above configured baseline',
      'trend': '+18%',
      'color': EnergyTheme.amberGlow,
    },
  ];

  final List<Map<String, dynamic>> _deviceAlerts = [
    {
      'device': 'Living Room Smart Plug',
      'status': 'Power cycling repeatedly',
      'timestamp': '2 min ago',
      'icon': Icons.power_settings_new,
    },
    {
      'device': 'Solar Inverter',
      'status': 'Firmware update pending',
      'timestamp': '24 min ago',
      'icon': Icons.bolt,
    },
  ];

  final List<Map<String, String>> _history = [
    {
      'title': 'Automation schedule executed',
      'time': 'Today · 07:00 AM',
    },
    {
      'title': 'Garage heater turned off remotely',
      'time': 'Yesterday · 09:44 PM',
    },
    {
      'title': 'Subscription renewed',
      'time': 'Wed · 11:05 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Today', 'Critical', 'Muted'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () {},
            tooltip: 'Archive',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Wrap(
            spacing: 12,
            children: List.generate(filters.length, (index) {
              final bool isSelected = index == _selectedFilter;
              return ChoiceChip(
                label: Text(filters[index]),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedFilter = index),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: EnergyTheme.electricBlue,
                backgroundColor: EnergyTheme.panel,
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.2),
                ),
              );
            }),
          ),
          const SizedBox(height: 22),
          const EnergySectionHeader(
            title: 'High Power Usage',
            subtitle: 'Live watch on devices exceeding configured thresholds',
          ),
          ..._highUsageAlerts.map((alert) {
            return EnergyGlowCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          (alert['color'] as Color).withOpacity(0.2),
                          EnergyTheme.panel,
                        ],
                      ),
                    ),
                    child: Icon(Icons.flash_on, color: alert['color'] as Color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert['device'] as String,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert['status'] as String,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        alert['value'] as String,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: alert['color'] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        alert['trend'] as String,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          EnergyGlowCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mute critical alerts',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Temporarily pause notifications for maintenance windows.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _muteCritical,
                  onChanged: (value) => setState(() => _muteCritical = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const EnergySectionHeader(
            title: 'Device Malfunction',
            subtitle: 'Automated diagnostics surfaced instantly',
          ),
          ..._deviceAlerts.map(
            (alert) => EnergyGlowCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EnergyTheme.electricBlue.withOpacity(0.12),
                  ),
                  child: Icon(alert['icon'] as IconData, color: EnergyTheme.electricBlue),
                ),
                title: Text(alert['device'] as String),
                subtitle: Text(
                  alert['status'] as String,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  alert['timestamp'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const EnergySectionHeader(
            title: 'Timeline',
            subtitle: 'Notification history synced across devices',
          ),
          EnergyGlowCard(
            child: Column(
              children: _history.map((entry) {
                final bool isLast = entry == _history.last;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: EnergyTheme.electricBlue,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.white12,
                          ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['title'] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry['time'] ?? '',
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: EnergyTheme.neonPurple,
        onPressed: () {},
        icon: const Icon(Icons.done_all),
        label: const Text('Mark all read'),
      ),
    );
  }
}




