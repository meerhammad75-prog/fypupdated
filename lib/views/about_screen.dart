import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

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
          title: const Text("About Voltify", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent, elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xff23ABC3).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.bolt, size: 60, color: Color(0xff23ABC3)),
                ),
                const SizedBox(height: 20),
                const Text("Voltify App", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text("v1.0.0", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                const Text(
                  "Control your home energy smarter, faster, and from anywhere in the world.",
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),
                const Text("Developed by Your Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}