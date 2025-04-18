import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(const SchoolComputerTrackingApp());

class SchoolComputerTrackingApp extends StatelessWidget {
  const SchoolComputerTrackingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _currentIndex == 1
        ? const QRScanPage()
        : Scaffold(
            appBar: AppBar(
              title: const Text('School Computer Tracking'),
              backgroundColor: Colors.blueAccent,
              actions: const [Icon(Icons.notifications_none), SizedBox(width: 10)],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildCard(
                          title: 'Total Computers',
                          child: Column(
                            children: const [
                              Text('125', style: TextStyle(fontSize: 32, color: Colors.green)),
                              Text('95 ONLINE | 30 OFFLINE', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildCard(
                          title: 'Recent Activity',
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Student_Laptop3\nApp used'),
                              Text('Student_Laptop6\nWebsite example.com'),
                              Text('Teacher_Laptop1\nApp used Presentation'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: const Text('Computer Location'),
                        subtitle: const Text('Student_Laptop1'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildCard(
                          title: 'Assigned Users',
                          child: const Column(
                            children: [
                              Icon(Icons.map, color: Colors.green),
                              SizedBox(height: 10),
                              Text('Student_Laptop1'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text('Assigned Users'),
                                  const SizedBox(height: 10),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        width: 80,
                                        child: CircularProgressIndicator(
                                          value: 0.45,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.grey.shade300,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const Text('45%\nStudents', textAlign: TextAlign.center),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Teachers 30%'),
                                  const Text('Staff 25%'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: Colors.blueAccent,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'QR Scan'),
                BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
              ],
            ),
          );
  }

  Expanded _buildCard({required String title, required Widget child}) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
        ),
      );
}

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String code = '';

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('QR Scanner'), backgroundColor: Colors.blueAccent),
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: QRView(key: qrKey, onQRViewCreated: (ctrl) {
                controller = ctrl;
                controller!.scannedDataStream.listen((scanData) {
                  controller?.pauseCamera(); // Pause after scanning
                  setState(() => code = scanData.code ?? '');
                });
              }),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  code.isEmpty ? 'Scan a code' : 'Result: $code',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      );
}
