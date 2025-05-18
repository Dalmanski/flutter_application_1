import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_page.dart';
import 'select_settings.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SettingsPage extends StatefulWidget {
  final Function onSettingsUpdated;

  const SettingsPage({super.key, required this.onSettingsUpdated});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotification = false;
  late Future<String> _userRoleFuture;

  @override
  void initState() {
    super.initState();
    _userRoleFuture = _fetchUserRole();
    _loadPreferences();
    _logSharedPreferencesData();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotification = prefs.getBool('notification_enabled') ?? false;
    });
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_id', '');
  }

  void _logSharedPreferencesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()) {
      final value = prefs.get(key);
      logger.f("$key: $value");
    }
  }

  Future<String> _fetchUserRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accountId = prefs.getString('account_id');

      if (accountId == null) return "Unknown";

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(accountId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['role'] ?? "Unknown";
      } else {
        return "Unknown";
      }
    } catch (e) {
      logger.e("Error fetching user role: $e");
      return "Unknown";
    }
  }

  void showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Confirm Logout"),
          ],
        ),
        content: const Text("Are you sure you want to log-out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
                (route) => false,
              );
            },
            child: const Text("Yes, Log Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE6FC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: const BoxDecoration(
                color: Color(0xFF7B61FF),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.settings, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // User Role Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF7B61FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _userRoleFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Loading...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              "Error",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          } else {
                            final role = _capitalize(
                              snapshot.data ?? "Unknown",
                            );
                            return Text(
                              role,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Settings Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSettingsCard([
                    _buildSwitchTile(
                      Icons.notifications_active,
                      "Notification",
                      isNotification,
                      (val) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        setState(() {
                          isNotification = val;
                        });
                        await prefs.setBool('notification_enabled', val);
                        widget.onSettingsUpdated();
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildListTile(
                      Icons.help_outline,
                      "FAQ",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SelectSettingsPage(mode: 'faq'),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      Icons.mail_outline,
                      "Contact Us",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SelectSettingsPage(mode: 'contact'),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildListTile(
                      Icons.logout,
                      "Log Out",
                      onTap: showLogoutConfirmationDialog,
                    ),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String name) {
    return name.isEmpty
        ? name
        : name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7B61FF)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF7B61FF)),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF7B61FF),
    );
  }
}
