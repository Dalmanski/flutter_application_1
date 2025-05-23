import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'qrcode.dart';
import 'register_pc.dart';
import 'settings.dart';
import 'welcome_page.dart';
import 'available_pc.dart';
import 'announcements.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('account_id')) {
    await prefs.setString('account_id', '');
  }

  String? accountId = prefs.getString('account_id');

  bool accountExists = false;

  if (accountId != null && accountId.isNotEmpty) {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(accountId)
            .get();
    accountExists = doc.exists;
  }

  runApp(accountExists ? const StartHomeApp() : const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
      home: const WelcomePage(),
    );
  }
}

class StartHomeApp extends StatelessWidget {
  const StartHomeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
    home: const MainScaffold(),
  );
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  String? _role;
  bool _showNotification = true;

  void _onSettingsUpdated() {
    setState(() {
      _fetchSettings();
    });
  }

  List<Widget> get _pages {
    return [
      const HomeContent(),
      const QRScanPage(),
      SettingsPage(onSettingsUpdated: _onSettingsUpdated),
    ];
  }

  void toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void switchToPage(int index) {
    setState(() {
      _currentIndex = index;
      _isMenuOpen = false;
    });
  }

  Future<void> _fetchSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('account_id');
    _showNotification = prefs.getBool('notification_enabled') ?? true;

    if (accountId != null && accountId.isNotEmpty) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(accountId)
              .get();
      final data = doc.data();
      _role = data?['role'];
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF6A48D7),
              leading:
                  _role == 'technician'
                      ? IconTheme(
                        data: const IconThemeData(color: Colors.white),
                        child: IconButton(
                          onPressed: toggleMenu,
                          icon: const Icon(Icons.menu),
                        ),
                      )
                      : null,
              actions: [
                if (_showNotification)
                  IconTheme(
                    data: const IconThemeData(color: Colors.white),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnnouncementsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ),
              ],
              title: const Text(
                'CompStat',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
            body: _pages[_currentIndex],
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                selectedItemColor: const Color(0xFF6A48D7),
                onTap: switchToPage,
                backgroundColor: Colors.white,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                      size: _currentIndex == 0 ? 30 : 24,
                      color:
                          _currentIndex == 0
                              ? const Color(0xFF6A48D7)
                              : Colors.grey,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _currentIndex == 1 ? 56 : 48,
                      height: _currentIndex == 1 ? 56 : 48,
                      decoration: BoxDecoration(
                        color:
                            _currentIndex == 1
                                ? const Color(0xFF6A48D7)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF6A48D7),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.qr_code,
                        color:
                            _currentIndex == 1
                                ? Colors.white
                                : const Color(0xFF6A48D7),
                        size: _currentIndex == 1 ? 30 : 24,
                      ),
                    ),
                    label: 'QR Code',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.settings,
                      size: _currentIndex == 2 ? 30 : 24,
                      color:
                          _currentIndex == 2
                              ? const Color(0xFF6A48D7)
                              : Colors.grey,
                    ),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
          if (_role == 'technician')
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: 75,
              bottom: 550,
              left: _isMenuOpen ? 0 : -250,
              child: CustomSidebarMenu(
                onClose: toggleMenu,
                onSelect: (index) => switchToPage(index),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomSidebarMenu extends StatelessWidget {
  final VoidCallback onClose;
  final Function(int index) onSelect;

  const CustomSidebarMenu({
    super.key,
    required this.onClose,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 250,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 24, 21, 37),
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 1),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                shrinkWrap: true,
                children: [
                  _gridMenuButton(Icons.add, "Register", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreatePCPage()),
                    );
                  }),
                  _gridMenuButton(Icons.computer, "All PC's", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AvailableComputersPage(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridMenuButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 75, 66, 89),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
