import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AvailableComputersPage extends StatelessWidget {
  const AvailableComputersPage({super.key});

  Future<Map<String, List<Map<String, dynamic>>>>
  fetchAllComlabsAndPCs() async {
    final comlabSnapshot =
        await FirebaseFirestore.instance.collection('comlab rooms').get();

    Map<String, List<Map<String, dynamic>>> data = {};

    for (var comlabDoc in comlabSnapshot.docs) {
      final comlabName = comlabDoc.id;
      final pcsSnapshot =
          await FirebaseFirestore.instance
              .collection('comlab rooms')
              .doc(comlabName)
              .collection('PCs')
              .get();

      final pcs =
          pcsSnapshot.docs.map((doc) {
            final status = doc['status']?.toString().toLowerCase() ?? '';
            return {
              'pc_name': doc.id,
              'status': status,
              'date_reported': doc['date_reported'] ?? '',
              'time_reported': doc['time_reported'] ?? '',
              'generated_link': doc['generated_link'] ?? '',
              'last_issue': doc['last_issue'] ?? '',
            };
          }).toList();

      data[comlabName] = pcs;
    }

    return data;
  }

  void _showQRCodeModal(BuildContext context, String link) {
    if (link.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR code not available')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: QrImageView(
                data: link,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
    );
  }

  Icon _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'maintenance':
        return const Icon(Icons.error, color: Colors.orange);
      case 'unresolved':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.device_unknown, color: Colors.grey);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'not working':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label: $value', style: const TextStyle(fontSize: 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Available Computers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF083D77),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: fetchAllComlabsAndPCs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No comlab data found.'));
          }

          final comlabs = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: comlabs.keys.length,
            separatorBuilder: (_, __) => const Divider(thickness: 2),
            itemBuilder: (context, index) {
              final comlabName = comlabs.keys.elementAt(index);
              final pcs = comlabs[comlabName]!;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comlabName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF083D77),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...pcs.map((pc) {
                      final status = pc['status'];
                      final isMaintenance = status == 'maintenance';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.black26),
                        ),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          childrenPadding: const EdgeInsets.all(12),
                          leading: const Icon(Icons.desktop_windows_rounded),
                          title: Row(
                            children: [
                              Text(
                                pc['pc_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _statusIcon(status),
                              const SizedBox(width: 6),
                              Text(
                                status[0].toUpperCase() + status.substring(1),
                                style: TextStyle(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isMaintenance) ...[
                                    _infoRow(
                                      'Date Reported',
                                      pc['date_reported'],
                                    ),
                                    _infoRow(
                                      'Time Reported',
                                      pc['time_reported'],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Reported Issue:',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    Text(
                                      '  "${pc['last_issue']}"',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ] else ...[
                                    _infoRow(
                                      'Date Inspected',
                                      pc['date_reported'],
                                    ),
                                    _infoRow(
                                      'Time Inspected',
                                      pc['time_reported'],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => _showQRCodeModal(
                                      context,
                                      pc['generated_link'],
                                    ),
                                icon: const Icon(Icons.qr_code_2),
                                label: const Text("Show QR"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A48D7),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
