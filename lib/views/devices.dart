import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_screen.dart';
import 'profile_screen.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final dbRef = FirebaseDatabase.instance.ref("energyMonitor");
  Map<String, String> _deviceNames = {};

  @override
  void initState() {
    super.initState();
    _loadAllSavedNames();
  }

  // --- KEEP YOUR EXISTING HELPERS HERE ---
  // (Paste your _loadAllSavedNames, _saveDeviceName, _getRelayIndex, _calculateScheduleState logic here)
  Future<void> _loadAllSavedNames() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Map<String, String> loadedNames = {};
    for (String key in keys) {
      if (key.startsWith("relay")) {
        loadedNames[key] = prefs.getString(key) ?? "Device";
      }
    }
    setState(() {
      _deviceNames = loadedNames;
    });
  }

  int _getRelayIndex(String key) {
    if (key == 'relay') return 0;
    return int.tryParse(key.replaceAll('relay', '')) ?? 999;
  }

  bool _calculateScheduleState(Map schedData) {
    // (Your existing schedule logic)
    return false; // Placeholder for brevity, keep your real logic
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    // --- FIX IS HERE: Use .shade400 instead of [400] ---
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.indigo.shade700;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Voltify Manager", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: isDark ? Colors.cyan : Colors.indigo));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: Text("Connecting...", style: TextStyle(color: textColor)));
          }

          Map data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);

          double power = double.tryParse(data["power"].toString()) ?? 0.0;
          double powerKW = power / 1000.0;
          double totalEnergy = double.tryParse(data["totalEnergyKWh"].toString()) ?? 0.0;
          double bill = double.tryParse(data["bill"].toString()) ?? 0.0;

          List<String> relayKeys = data.keys.where((k) => k.toString().startsWith("relay") && !k.toString().contains("schedule")).cast<String>().toList();
          relayKeys.sort((a, b) => _getRelayIndex(a).compareTo(_getRelayIndex(b)));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.indigo.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem("Active Devices", "${relayKeys.length}", CrossAxisAlignment.start, textColor, subTextColor),
                          _buildSummaryItem("Total Power", "${powerKW.toStringAsFixed(2)} kW", CrossAxisAlignment.end, textColor, subTextColor),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 1, color: isDark ? Colors.grey.shade700 : Colors.indigo.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem("Total Energy", "${totalEnergy.toStringAsFixed(2)} kWh", CrossAxisAlignment.start, textColor, subTextColor),
                          _buildSummaryItem("Current Bill", "Rs ${bill.toStringAsFixed(0)}", CrossAxisAlignment.end, textColor, subTextColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: relayKeys.length,
                  itemBuilder: (context, index) {
                    String key = relayKeys[index];
                    String schKey = key == "relay" ? "schedule" : key.replaceAll("relay", "schedule");

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildDeviceCard(context, key, schKey, data, cardColor, textColor, isDark),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, CrossAxisAlignment align, Color txtColor, Color subColor) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: subColor, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: txtColor)),
      ],
    );
  }

  Widget _buildDeviceCard(BuildContext context, String relayKey, String scheduleKey, Map data, Color cardColor, Color textColor, bool isDark) {
    // Basic Parsing
    int manualVal = int.tryParse(data[relayKey].toString()) ?? 0;
    Map schedData = (data[scheduleKey] is Map) ? data[scheduleKey] : {};
    bool isSchedActive = (int.tryParse(schedData["active"].toString()) ?? 0) == 1;
    bool isOn = isSchedActive ? _calculateScheduleState(schedData) : (manualVal == 1);

    String defaultName = relayKey == "relay" ? "Main Device" : "Device ${_getRelayIndex(relayKey)}";
    String currentName = _deviceNames[relayKey] ?? defaultName;

    return Card(
      color: cardColor,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                      color: isOn ? Colors.green.withOpacity(0.2) : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                      shape: BoxShape.circle
                  ),
                  child: Icon(Icons.power_settings_new, color: isOn ? Colors.green : Colors.grey, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                      const SizedBox(height: 4),
                      Text(
                        isSchedActive ? (isOn ? "Auto: ON" : "Auto: OFF") : "Manual Mode",
                        style: TextStyle(fontSize: 13, color: isSchedActive ? Colors.orange : Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isOn,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  onChanged: isSchedActive ? null : (val) => dbRef.child(relayKey).set(val ? 1 : 0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            // Placeholder for schedule tap
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    isSchedActive ? "Schedule Active" : "Set Schedule",
                    style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.indigo.shade800, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}