import 'package:flutter/material.dart';
import 'home.dart';
import 'qrcode.dart';
import 'maintenance.dart';

void main() => runApp(const SchoolComputerTrackingApp());

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
              backgroundColor: const Color(0xFF6A48D7),
              leading: IconButton(
                onPressed: toggleMenu,
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                ),
              ],
            ),
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xFF6A48D7),
              onTap: (index) => setState(() => _currentIndex = index),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6A48D7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code, color: Colors.white, size: 28),
                  ),
                  label: 'QR Code',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.schedule),
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
