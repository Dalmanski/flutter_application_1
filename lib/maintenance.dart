import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  Map<String, List<Map<String, dynamic>>> maintenanceMap = {};
  bool isLoading = true; // 🛠 Add loading state

  @override
  void initState() {
    super.initState();
    fetchPCs();
  }

  Future<void> fetchPCs() async {
    final comlabCollection = FirebaseFirestore.instance.collection('comlab rooms');
    final comlabSnapshot = await comlabCollection.get();

    if (!mounted) return;

    Map<String, List<Map<String, dynamic>>> tempMap = {};

    for (var comlabDoc in comlabSnapshot.docs) {
      final comlabName = comlabDoc.id;
      final pcsCollection = comlabDoc.reference.collection('PCs');
      final pcsSnapshot = await pcsCollection.get();

      List<Map<String, dynamic>> pcsList = [];

      for (var pcDoc in pcsSnapshot.docs) {
        final data = pcDoc.data();
        final status = data['status'] ?? 'unknown';

        if (status == 'maintenance') {
          final pcData = {
            'pc': pcDoc.id,
            'isExpanded': false,
            'status': status,
            'date': data['date_reported'] ?? '',
            'time': data['time_reported'] ?? '',
            'issue': data['last_issue'],
          };
          pcsList.add(pcData);
        }
      }

      tempMap[comlabName] = pcsList;
    }

    if (mounted) {
      setState(() {
        maintenanceMap = tempMap;
        isLoading = false; // ✅ Loading complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // 🌀 Loading indicator
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEAFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.computer, color: Colors.black87),
                      SizedBox(width: 10),
                      Text(
                        'Maintenance Schedule',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('On Maintenance', style: TextStyle(fontSize: 16, color: Colors.red)),
                const Divider(color: Colors.redAccent),

                if (maintenanceMap.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No PCs currently under maintenance.',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  )
                else
                  ...maintenanceMap.entries.map((entry) {
                    final comlab = entry.key;
                    final pcs = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            comlab.toUpperCase(),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        const Divider(),

                        if (pcs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No PCs under maintenance.',
                              style: TextStyle(color: Colors.green),
                            ),
                          )
                        else
                          ...pcs.map(buildMaintenanceCard),
                      ],
                    );
                  }),
              ],
            ),
    );
  }

  Widget buildMaintenanceCard(Map<String, dynamic> data) {
    final isExpanded = data['isExpanded'] as bool;

    return GestureDetector(
      onTap: () {
        setState(() {
          data['isExpanded'] = !data['isExpanded'];
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build_circle, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${data['pc']} Maintenance',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${data['date']}'),
                    Text('Time: ${data['time']}'),
                    Row(
                      children: [
                        const Text('Status: '),
                        Text(
                          data['status'],
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                    if (data['issue'] != null) ...[
                      const SizedBox(height: 10),
                      const Text('User Issue:', style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 6),
                      Text(
                        '"${data['issue']}"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
