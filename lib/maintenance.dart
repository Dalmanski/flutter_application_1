import 'package:flutter/material.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final List<Map<String, dynamic>> priorityList = [
    {
      'pc': 'PC 1',
      'isExpanded': false,
      'status': 'working',
      'date': '2025-05-01',
      'time': '10:00 AM',
      'isUrgent': true,
    },
    {
      'pc': 'PC 3',
      'isExpanded': false,
      'status': 'maintenance',
      'date': '2025-05-02',
      'time': '11:11 AM',
      'isUrgent': true,
      'issue': 'Missing peripherals. I can’t use the computer without a mouse. Where is the mouse. The PC does not have a keyboard as well.',
    },
  ];

  final List<Map<String, dynamic>> nonUrgentList = [
    {
      'pc': 'PC 1',
      'isExpanded': false,
      'status': 'working',
      'date': '2025-05-01',
      'time': '10:00 AM',
      'isUrgent': false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
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
          const Text('Priority', style: TextStyle(fontSize: 16, color: Colors.red)),
          const Divider(color: Colors.redAccent),
          ...priorityList.map(buildMaintenanceCard),
          const SizedBox(height: 20),
          const Text('Non - Urgent', style: TextStyle(fontSize: 16)),
          const Divider(),
          ...nonUrgentList.map(buildMaintenanceCard),
        ],
      ),
    );
  }

  Widget buildMaintenanceCard(Map<String, dynamic> data) {
    final isExpanded = data['isExpanded'] as bool;
    final isUrgent = data['isUrgent'] as bool;

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
                Icon(Icons.circle, size: 12, color: isUrgent ? Colors.red : Colors.orange),
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
                        if (data['status'] == 'working')
                          Text(
                            data['status'],
                            style: const TextStyle(color: Colors.green),
                          )
                        else
                          Text(
                            data['status'],
                            style: const TextStyle(color: Colors.orange),
                          ),
                      ],
                    ),
                    if (data.containsKey('issue')) ...[
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
              )
            ],
          ],
        ),
      ),
    );
  }
}
