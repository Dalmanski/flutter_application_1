import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'main.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

Future<String> storeDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();
  String deviceName = 'Unknown';

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    deviceName = androidInfo.model;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    deviceName = iosInfo.name;
  }

  return deviceName;
}

class _WelcomePageState extends State<WelcomePage> {
  String? selectedRole;

  void _handleGetStarted() async {
    if (selectedRole == "Student") {
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (_) => const StudentConfirmationDialog(),
      );

      if (shouldProceed == true && context.mounted) {
        final deviceInfo = DeviceInfoPlugin();
        String? deviceId;
        String deviceName = await storeDeviceName();

        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor;
        }

        if (deviceId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to retrieve device ID")),
          );
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('account_id', deviceId);

        await FirebaseFirestore.instance.collection('users').doc(deviceId).set({
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
          'username': 'NA',
          'password': 'NA',
          'deviceName': deviceName,
        }, SetOptions(merge: true)); // Overwrite or merge if already exists

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SchoolComputerTrackingApp()),
        );
      }
    } else if (selectedRole == "Technician") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TechnicianLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF7B61FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 20, top: 40),
                child: Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "I am a...",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRoleCard("Student", Icons.people_alt_outlined),
                const SizedBox(width: 20),
                _buildRoleCard("Technician", Icons.work_outline),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: selectedRole != null ? _handleGetStarted : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.deepPurple),
            const SizedBox(height: 15),
            Text(
              role,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ), // Increased font size
            ),
          ],
        ),
      ),
    );
  }
}

class StudentConfirmationDialog extends StatelessWidget {
  const StudentConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 10),
          const Text(
            "Are you sure?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "You will not be able to change your role later",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(
                    context,
                  ).pop(true); // This is to prevent click back button
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  "Yes, Proceed",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  "No, Go Back",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------- Technician Login Page --------------------

class TechnicianLoginPage extends StatefulWidget {
  const TechnicianLoginPage({super.key});

  @override
  State<TechnicianLoginPage> createState() => _TechnicianLoginPageState();
}

class _TechnicianLoginPageState extends State<TechnicianLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _attemptLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .where('role', isEqualTo: 'technician')
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final accountId = doc.id;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful")));

        String device = await storeDeviceName();
        await FirebaseFirestore.instance.collection('users').doc(accountId).set(
          {'loginOn': FieldValue.serverTimestamp(), 'deviceName': device},
          SetOptions(merge: true),
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('account_id', accountId);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SchoolComputerTrackingApp()),
          (Route<dynamic> route) => false, // This removes all previous routes
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B61FF), Color(0xFFBBA9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Technician",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: _usernameController,
                          icon: Icons.person,
                          hint: "Username",
                          obscureText: false,
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(
                          controller: _passwordController,
                          icon: Icons.vpn_key,
                          hint: "Password",
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _attemptLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 12,
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Log In",
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Go Back",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
        ),
      ),
    );
  }
}
