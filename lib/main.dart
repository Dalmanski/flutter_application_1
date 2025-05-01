import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'qrcode.dart';
import 'maintenance.dart';
import 'register_pc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // initialize Firebase
  runApp(const SchoolComputerTrackingApp());
}

class SchoolComputerTrackingApp extends StatelessWidget {
  const SchoolComputerTrackingApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
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

  final List<Widget> _pages = [
    const HomeContent(),
    const QRScanPage(),
    const MaintenancePage(),
  ];

  void toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6A48D7), // Purple
                      Color(0xFF8E2DE2), // Vibrant purple
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: toggleMenu,
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xFF6A48D7),
              onTap: (index) => setState(() => _currentIndex = index),
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
                    Icons.schedule,
                    size: _currentIndex == 2 ? 30 : 24,
                    color:
                        _currentIndex == 2
                            ? const Color(0xFF6A48D7)
                            : Colors.grey,
                  ),
                  label: 'Schedules',
                ),
              ],
            ),
          ),

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: _isMenuOpen ? 0 : -250,
            child: CustomSidebarMenu(onClose: toggleMenu),
          ),
        ],
      ),
    );
  }
}

class CustomSidebarMenu extends StatelessWidget {
  final VoidCallback onClose;

  const CustomSidebarMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Container(
        width: 250,
        decoration: const BoxDecoration(color: Color.fromARGB(255, 24, 21, 37)),
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onClose,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            _menuButton(Icons.build, "Maintenance Schedule", () {}),
            const SizedBox(height: 10),
            const Divider(
              color: Colors.white,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            const SizedBox(height: 10),
            _menuButton(Icons.settings, "Settings", () {}),
            const SizedBox(height: 10),
            _menuButton(Icons.add, "Register New PC", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePCPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(IconData icon, String title, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 75, 66, 89),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(color: Colors.white)),
      onPressed: onPressed,
    );
  }
}
