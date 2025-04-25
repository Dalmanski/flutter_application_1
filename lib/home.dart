import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

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
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(158, 158, 158, 1),
                spreadRadius: 4,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'http://rshsxii.edu.ph/wp-content/uploads/2013/10/wpid-IMG_20131008_133012.jpg',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
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
                            value: 0.7,
                            strokeWidth: 20,
                            backgroundColor: Colors.white,
                            color: const Color(0xFF6A48D7),
                          ),
                        ),
                        Container(
                          height: 95,
                          width: 95,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '70%',
                              style: TextStyle(
                                color: Color(0xFF6A48D7),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
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
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'Status: ',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Text(
                      'Open',
                      style: TextStyle(color: Colors.green, fontSize: 16),
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
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Available Computers'),
                      content: const Text(
                          'Total: 125\nOnline: 95\nOffline: 30\n\nDetails:\nStudent_Laptop1\nStudent_Laptop2\n...'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Available Computers'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF6A48D7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  DefaultTabController.of(context).animateTo(2);
                },
                child: const Text('Room Schedule'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 24, 21, 37),
        ),
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
            _menuButton(Icons.build, "Maintenance Schedule"),
            const SizedBox(height: 10),
            const Divider(
              color: Colors.white,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            const SizedBox(height: 10),
            _menuButton(Icons.settings, "Settings"),
            const SizedBox(height: 10),
            _menuButton(Icons.help_outline, "Placeholder 1"),
            const SizedBox(height: 10),
            _menuButton(Icons.help_outline, "Placeholder 2"),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(IconData icon, String title) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 75, 66, 89),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(color: Colors.white)),
      onPressed: () {
        // Implement feature here
      },
    );
  }
}
