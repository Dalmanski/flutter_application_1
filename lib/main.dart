import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'qrcode.dart';
import 'register_pc.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

  void toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void switchToPage(int index) {
    setState(() {
      _currentIndex = index;
      _isMenuOpen = false;
    });
  }

  final List<Widget> _pages = const [
    HomeContent(),
    QRScanPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconTheme(
                data: IconThemeData(
                  color: Colors.white,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(2, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: toggleMenu,
                  icon: Icon(Icons.menu),
                ),
              ),
              actions: [
                IconTheme(
                  data: IconThemeData(
                    color: Colors.white,
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2, 2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications_none),
                  ),
                ),
              ],
              title: Material(
                color: Colors.transparent,
                child: Text(
                  'CompStat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      Shadow(
                        offset: Offset(-1, 1),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      Shadow(
                        offset: Offset(1, -1),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      Shadow(
                        offset: Offset(-1, -1),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2, 2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
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

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
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
      elevation: 8,
      child: Container(
        width: 250,
        color: const Color.fromARGB(255, 24, 21, 37),
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onClose,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            _menuButton(Icons.add, "Register New PC", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePCPage()),
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
