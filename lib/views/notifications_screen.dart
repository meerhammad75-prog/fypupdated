import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool billAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('settings').doc('notifications').get();

    if (doc.exists) {
      Map data = doc.data()!;
      setState(() {
        pushEnabled = data['push'] ?? true;
        emailEnabled = data['email'] ?? false;
        billAlerts = data['bill'] ?? true;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateSetting(String key, bool value) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      if (key == 'push') pushEnabled = value;
      if (key == 'email') emailEnabled = value;
      if (key == 'bill') billAlerts = value;
    });
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('settings').doc('notifications').set({
      key: value
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xff23ABC3), Colors.white],
          begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.0, 0.4, 0.9],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent, elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.notifications_active, color: Colors.white, size: 60),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    _buildSwitch(Icons.smartphone, "Push Notifications", "Receive alerts on this phone", pushEnabled, (v) => _updateSetting('push', v)),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _buildSwitch(Icons.email_outlined, "Email Alerts", "Receive bill summaries via email", emailEnabled, (v) => _updateSetting('email', v)),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _buildSwitch(Icons.bolt, "High Usage Warning", "Alert when usage spikes", billAlerts, (v) => _updateSetting('bill', v)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xff23ABC3).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xff23ABC3)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)), // Force Black
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)), // Force Grey
        value: value,
        activeColor: const Color(0xff23ABC3),
        onChanged: onChanged,
      ),
    );
  }
}