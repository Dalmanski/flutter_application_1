import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'register_pc.dart';
import 'available_pc.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> comlabs = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComlabs();
  }

  Future<void> fetchComlabs() async {
    try {
      final QuerySnapshot roomsSnapshot =
          await FirebaseFirestore.instance.collection('comlab rooms').get();

      List<Map<String, dynamic>> fetchedComlabs = [];

      for (var roomDoc in roomsSnapshot.docs) {
        final roomName = roomDoc.id;
        final roomData = roomDoc.data() as Map<String, dynamic>;
        final imageUrl = roomData['image'] ?? '';

        final pcsSnapshot =
            await FirebaseFirestore.instance
                .collection('comlab rooms')
                .doc(roomName)
                .collection('PCs')
                .get();

        int totalPCs = pcsSnapshot.docs.length;
        int workingPCs =
            pcsSnapshot.docs
                .where(
                  (doc) => (doc['status'] ?? '').toLowerCase() == 'working',
                )
                .length;

        double occupied = totalPCs == 0 ? 0 : workingPCs / totalPCs;

        fetchedComlabs.add({
          'name': roomName,
          'occupied': occupied,
          'image': imageUrl,
        });
      }

      setState(() {
        comlabs = fetchedComlabs;
        isLoading = false;
      });
    } catch (e) {
      //print('Error loading comlabs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://img.freepik.com/free-vector/modern-colorful-poster-shape-color-background_361591-4374.jpg?t=st=1745552015~exp=1745555615~hmac=ee9e7fdc1c2d543db870597796bfa66fa6b2e1ebe9796d1d439166918f947440&w=360',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : comlabs.isEmpty
                ? const Text('No Comlabs Found')
                : Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 4,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        comlabs[currentIndex]['name'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A48D7),
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: comlabs.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    comlabs[index]['image'] ?? '',
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height: 95,
                                        width: 95,
                                        child: CircularProgressIndicator(
                                          value: comlabs[index]['occupied'],
                                          strokeWidth: 20,
                                          backgroundColor: Colors.white,
                                          color: const Color(0xFF6A48D7),
                                        ),
                                      ),
                                      Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${(comlabs[index]['occupied'] * 100).toInt()}%',
                                            style: const TextStyle(
                                              color: Color(0xFF6A48D7),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'are occupied',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: comlabs.length,
                        effect: const WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          activeDotColor: Color(0xFF6A48D7),
                          dotColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Open',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF6A48D7),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AvailableComputersPage(
                                    comlabName: comlabs[currentIndex]['name'],
                                  ),
                            ),
                          );
                        },
                        child: const Text('Available Computers'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporting issue...')),
                          );
                        },
                        child: const Text('Report an Issue'),
                      ),
                    ],
                  ),
                ),
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
