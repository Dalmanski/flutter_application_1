import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailableComputersPage extends StatelessWidget {
  final String comlabName;

  const AvailableComputersPage({super.key, required this.comlabName});

  Future<List<Map<String, dynamic>>> fetchPCs() async {
    final pcsSnapshot = await FirebaseFirestore.instance
        .collection('comlab rooms')
        .doc(comlabName)
        .collection('PCs')
        .get();

    return pcsSnapshot.docs.map((doc) {
      return {
        'comlab': comlabName,
        'date_reported': doc['date_reported'] ?? '',
        'status': doc['status'] ?? '',
        'time_reported': doc['time_reported'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$comlabName - Available PCs'),
        backgroundColor: const Color(0xFF6A48D7),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPCs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No PCs Found'));
          } else {
            final pcs = snapshot.data!;
            return ListView.builder(
              itemCount: pcs.length,
              itemBuilder: (context, index) {
                final pc = pcs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    title: Text('Status: ${pc['status']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date Reported: ${pc['date_reported']}'),
                        Text('Time Reported: ${pc['time_reported']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
