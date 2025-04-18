import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() => runApp(SchoolComputerTrackingApp());

class SchoolComputerTrackingApp extends StatelessWidget {
  const SchoolComputerTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('School Computer Tracking'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Icon(Icons.notifications_none),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Total Computers'),
                            SizedBox(height: 10),
                            Text('125', style: TextStyle(fontSize: 32, color: Colors.green)),
                            Text('95 ONLINE | 30 OFFLINE', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recent Activity'),
                            SizedBox(height: 10),
                            Text('Student_Laptop3\nApp used'),
                            Text('Student_Laptop6\nWebsite example.com'),
                            Text('Teacher_Laptop1\nApp used Presentation'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.green),
                  title: Text('Computer Location'),
                  subtitle: Text('Student_Laptop1'),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.map, color: Colors.green),
                                SizedBox(height: 10),
                                Text('Assigned Users'),
                                SizedBox(height: 10),
                                Text('Student_Laptop1'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Assigned Users'),
                            SizedBox(height: 10),
                            CircularPercentIndicator(
                              radius: 60.0,
                              lineWidth: 8.0,
                              percent: 0.45,
                              center: Text("45%\nStudents", textAlign: TextAlign.center,),
                              progressColor: Colors.blueAccent,
                            ),
                            SizedBox(height: 10),
                            Text('Teachers 30%'),
                            Text('Staff 25%'),
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
        selectedItemColor: Colors.blueAccent,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'QR Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
        ],
      ),
    );
  }
}
