import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// --- IMPORTS FOR NAVIGATION ---
import 'package:news_app/views/alerts_notifications_screen.dart';
import 'package:news_app/views/profile_screen.dart';
import 'package:news_app/views/settings_screen.dart';

import 'analytics.dart';
import 'devices.dart';
// IMPORT YOUR DEVICES SCREEN FILE HERE.
// Example: import 'path/to/devices_screen.dart';
// For now, I will assume the class is available in the project.

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref('sensorData');

  // --- NAVIGATION STATE ---
  int _selectedIndex = 0;

  double _voltage = 0.0;
  double _current = 0.0;

  StreamSubscription<DatabaseEvent>? _databaseSubscription;

  late AnimationController _controller;
  late Animation<Color?> _gradientColor;

  @override
  void initState() {
    super.initState();

    // Firebase data listener
    _databaseSubscription = _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        // Check if mounted to prevent setstate errors if user navigates away
        if (mounted) {
          setState(() {
            _voltage = double.tryParse(data['voltage'].toString()) ?? 0.0;
            _current = double.tryParse(data['current'].toString()) ?? 0.0;
          });
        }
      }
    });

    // Animation controller for gradient color
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Tween between your initial color and off-white/cream
    _gradientColor = ColorTween(
      begin: const Color(0xff23ABC3),
      end: const Color(0xffFFFDD0),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _databaseSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // --- HANDLE TAB TAPS ---
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We create the list of pages here so we can pass context if needed
    final List<Widget> _pages = [
      _buildDashboardView(),          // Index 0: Your original Home Dashboard
      const DevicesScreen(),          // Index 1: The Device Manager (Make sure class name matches)
      const EnergyStatisticsScreen(), // Index 2: Placeholder
      const Center(child: Text("Bill Screen")),  // Index 3: Placeholder
      const SettingsScreen() // Index 4: Placeholder
    ];

    return AnimatedBuilder(
      animation: _gradientColor,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _gradientColor.value ?? const Color(0xff23ABC3),
                const Color(0xff23ABC3),
                const Color(0xffFFFFFF),
              ],
            ),
          ),
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // Only show the Home AppBar if we are on the Home Tab (Index 0)
        // DevicesScreen has its own AppBar, so we hide this one to avoid double headers.
        appBar: _selectedIndex == 0 ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
            ),
          ),
          title: Text(
            'Energy Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AlertsNotificationsScreen.routeName),
              icon: const Icon(Icons.notifications_none, color: Colors.black),
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
              icon: const Icon(Icons.settings_outlined, color: Colors.black),
            ),
          ],
        ) : null, // Return null to hide AppBar on other tabs

        // Switch the body based on selected index
        body: _pages[_selectedIndex],

        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex, // Connect state
          onTap: _onItemTapped,         // Connect handler
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Usage'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Bill'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  // --- ORIGINAL HOME CONTENT MOVED HERE ---
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnergyCard(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Real-time Monitoring', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              Switch(value: true, onChanged: (value) {})
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildVoltageGauge()),
              const SizedBox(width: 10),
              Expanded(child: _buildCurrentGauge()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Connected Devices', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              // Optional: You can make "View All" switch to the devices tab
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Text('View All', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.arrow_forward_ios, size: 28, color: Colors.blue),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hair Dryer', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              const Spacer(),
              Text('On', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black))
            ],
          ),
          const SizedBox(height: 20),
          Text('Usage Summary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bar('Mon', 50),
              _bar('Tue', 80),
              _bar('Wed', 40),
              _bar('Thu', 70),
              _bar('Fri', 60),
              _bar('Sat', 90),
              _bar('Sun', 100),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEnergyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E90FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Energy Consumed', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 8),
              Text('284.5 kWh', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Current Bill', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              Text('PKR 14,225', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.flash_on, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+12.3%',
                  style: GoogleFonts.poppins(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVoltageGauge() {
    return SfRadialGauge(
      title: const GaugeTitle(
        text: 'Voltage (V)',
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      axes: [
        RadialAxis(
          minimum: 0,
          maximum: 250,
          interval: 50,
          showLabels: true,
          showTicks: true,
          axisLabelStyle: const GaugeTextStyle(fontSize: 12, color: Colors.black),
          axisLineStyle: const AxisLineStyle(
            thickness: 0.1,
            thicknessUnit: GaugeSizeUnit.factor,
            color: Colors.grey,
          ),
          ranges: [
            GaugeRange(startValue: 0, endValue: 80, color: Colors.green),
            GaugeRange(startValue: 80, endValue: 180, color: Colors.blueAccent),
            GaugeRange(startValue: 180, endValue: 250, color: Colors.redAccent),
          ],
          pointers: [
            NeedlePointer(
                needleStartWidth: 1,
                needleEndWidth: 5,
                value: _voltage, enableAnimation: true, needleColor: Colors.white)
          ],
          annotations: [
            GaugeAnnotation(
              widget: Text('${_voltage.toStringAsFixed(2)} V',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              angle: 90,
              positionFactor: 0.6,
            )
          ],
        )
      ],
    );
  }

  Widget _buildCurrentGauge() {
    return SfRadialGauge(
      title: const GaugeTitle(
        text: 'Current (A)',
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      axes: [
        RadialAxis(
          minimum: 0,
          maximum: 20,
          interval: 5,
          showLabels: true,
          showTicks: true,
          axisLabelStyle: const GaugeTextStyle(fontSize: 12, color: Colors.black),
          axisLineStyle: const AxisLineStyle(
            thickness: 0.1,
            thicknessUnit: GaugeSizeUnit.factor,
            color: Colors.grey,
          ),
          ranges: [
            GaugeRange(startValue: 0, endValue: 5, color: Colors.green),
            GaugeRange(startValue: 5, endValue: 15, color: Colors.blueAccent),
            GaugeRange(startValue: 15, endValue: 20, color: Colors.redAccent),
          ],
          pointers: [
            NeedlePointer(
                needleStartWidth: 1,
                needleEndWidth: 5,
                value: _current, enableAnimation: true, needleColor: Colors.white)
          ],
          annotations: [
            GaugeAnnotation(
              widget: Text('${_current.toStringAsFixed(2)} A',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              angle: 90,
              positionFactor: 0.6,
            )
          ],
        )
      ],
    );
  }

  Widget _bar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 12))
      ],
    );
  }
}