import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  String? accountId;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadAccountIdAndRole();
  }

  Future<void> _loadAccountIdAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('account_id');

    if (id != null && id.isNotEmpty) {
      setState(() {
        accountId = id;
      });

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      final data = doc.data();
      setState(() {
        _role = data?['role'];
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'unresolved':
      default:
        return Colors.red;
    }
  }

  Future<void> _clearAllNotifications() async {
    if (accountId == null) return;
    final collection = FirebaseFirestore.instance.collection('global announce');
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteNotification(String docId) async {
    if (accountId == null) return;
    await FirebaseFirestore.instance
        .collection('global announce')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    if (accountId == null || _role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final collection = FirebaseFirestore.instance
        .collection('global announce')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A48D7),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Back',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE1DDFE),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.announcement_outlined, color: Colors.black54),
                const SizedBox(width: 10),
                const Text(
                  "Announcements",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_role != 'student')
                  ElevatedButton(
                    onPressed: _clearAllNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: collection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "It's empty",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Map<String, List<QueryDocumentSnapshot>> grouped = {};
                for (var doc in docs) {
                  String date = doc['date'];
                  grouped.putIfAbsent(date, () => []).add(doc);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children:
                      grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  DateFormat(
                                    "MMMM, dd",
                                  ).format(DateTime.parse(entry.key)),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFFCBCBE3),
                                    thickness: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...entry.value.map((doc) {
                              final status = doc['status'];
                              final color = _getStatusColor(status);

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        doc['message'],
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (_role != 'student')
                                      IconButton(
                                        onPressed:
                                            () => _deleteNotification(doc.id),
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red[400],
                                        iconSize: 20,
                                      ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                          ],
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
