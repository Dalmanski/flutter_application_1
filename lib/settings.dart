import 'package:flutter/material.dart';
import 'welcome_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

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
                  children: const [
                    Icon(Icons.person, color: Colors.white, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Student",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
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
                    _buildListTile(Icons.school, "Student", onTap: () {}),
                    _buildListTile(
                      Icons.display_settings,
                      "Display",
                      onTap: () {},
                    ),
                    _buildSwitchTile(Icons.dark_mode, "Dark Mode", isDarkMode, (
                      val,
                    ) {
                      setState(() {
                        isDarkMode = val;
                      });
                    }),
                  ]),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildListTile(Icons.help_outline, "FAQ", onTap: () {}),
                    _buildListTile(
                      Icons.mail_outline,
                      "Contact Us",
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildListTile(
                      Icons.logout,
                      "Log Out",
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WelcomePage(),
                          ),
                          (route) => false,
                        );
                      },
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
