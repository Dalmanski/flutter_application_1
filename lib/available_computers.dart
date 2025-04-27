import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AvailableComputersPage extends StatelessWidget {
  final String comlabName;

  const AvailableComputersPage({super.key, required this.comlabName});

  Future<List<Map<String, dynamic>>> fetchPCs() async {
    final pcsSnapshot =
        await FirebaseFirestore.instance
            .collection('comlab rooms')
            .doc(comlabName)
            .collection('PCs')
            .get();

    return pcsSnapshot.docs.map((doc) {
      return {
        'pc_name': doc.id,
        'status': doc['status'] ?? '',
        'date_reported': doc['date_reported'] ?? '',
        'time_reported': doc['time_reported'] ?? '',
        'generated_link': doc['generated_link'] ?? '',
      };
    }).toList();
  }

  void _showQRCodeModal(BuildContext context, String generatedLink) {
    if (generatedLink.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR code not available')));
      return;
    }
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: QrImageView(
                data: generatedLink,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return Colors.green;
      case 'not working':
        return Colors.red;
      default:
        return Colors.orange;
    }
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
                final statusColor = _getStatusColor(pc['status']);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap:
                        () => _showQRCodeModal(context, pc['generated_link']),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEDEAFF), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pc['pc_name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A48D7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Status: ${pc['status']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Date Reported: ${pc['date_reported']}'),
                          Text('Time Reported: ${pc['time_reported']}'),
                        ],
                      ),
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
