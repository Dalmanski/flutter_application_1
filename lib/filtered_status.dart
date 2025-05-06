import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class FilteredStatusPage extends StatefulWidget {
  final String status;
  final String labName;

  const FilteredStatusPage({
    super.key,
    required this.status,
    required this.labName,
  });

  @override
  State<FilteredStatusPage> createState() => _FilteredStatusPageState();
}

class _FilteredStatusPageState extends State<FilteredStatusPage> {
  List<Map<String, dynamic>> filteredPCs = [];
  bool isLoading = true;
  String selectedStatus = 'Available';
  String? role;

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    await fetchUserRole();
    await fetchFilteredPCs();
  }

  Future<void> fetchUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('account_id');

    if (accountId != null && accountId.isNotEmpty) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(accountId)
              .get();
      final data = doc.data();
      if (mounted) {
        setState(() {
          role = data?['role'];
        });
      }
    }
  }

  Future<void> fetchFilteredPCs() async {
    final labDocRef = FirebaseFirestore.instance
        .collection('comlab rooms')
        .doc(widget.labName);

    final pcsSnapshot = await labDocRef.collection('PCs').get();

    List<Map<String, dynamic>> tempList = [];

    for (var pc in pcsSnapshot.docs) {
      final data = pc.data();
      final status = data['status'] ?? 'unknown';

      if (status.toLowerCase() == widget.status.toLowerCase()) {
        tempList.add({
          'pc': pc.id,
          'isExpanded': false,
          'status': status,
          'date': data['date_reported'] ?? '',
          'time': data['time_reported'] ?? '',
          'issue': data['last_issue'],
        });
      }
    }

    if (mounted) {
      setState(() {
        filteredPCs = tempList;
        isLoading = false;
      });
    }
  }

  Future<void> showStatusModal(String pcName) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0A57C2),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      widget.labName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    const Icon(Icons.computer, size: 48, color: Colors.black87),
                    const SizedBox(height: 8),
                    Text(
                      'Name: $pcName',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Available'),
                          value: 'Available',
                          groupValue: selectedStatus,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedStatus = value;
                              });
                              Navigator.of(context).pop();
                              showStatusModal(pcName);
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Unresolved'),
                          value: 'Unresolved',
                          groupValue: selectedStatus,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedStatus = value;
                              });
                              Navigator.of(context).pop();
                              showStatusModal(pcName);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final pcRef = FirebaseFirestore.instance
                            .collection('comlab rooms')
                            .doc(widget.labName)
                            .collection('PCs')
                            .doc(pcName);

                        await pcRef.update({
                          'status': selectedStatus.toLowerCase(),
                        });

                        if (!mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Status updated to "$selectedStatus" for $pcName.',
                            ),
                          ),
                        );

                        fetchFilteredPCs();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Update Status'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'unresolved':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available Units';
      case 'maintenance':
        return 'Maintenance Schedule';
      case 'unresolved':
        return 'Unresolved Units';
      default:
        return 'Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.labName.toUpperCase()} PC\'s',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEAFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.computer,
                          color: getStatusColor(widget.status),
                          size: 25,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          getStatusTitle(widget.status),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: Colors.grey, thickness: 1),
                  ),
                  Expanded(
                    child:
                        filteredPCs.isEmpty
                            ? Center(
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
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredPCs.length,
                              itemBuilder: (context, index) {
                                final pcData = filteredPCs[index];
                                final isExpanded = pcData['isExpanded'] as bool;
                                final pcStatus =
                                    pcData['status']
                                        ?.toString()
                                        .toLowerCase() ??
                                    '';

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      pcData['isExpanded'] = !isExpanded;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.black26),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 16,
                                              color: getStatusColor(pcStatus),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                pcData['pc'] ?? 'Unknown',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                            ),
                                          ],
                                        ),
                                        AnimatedSize(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                          child:
                                              isExpanded
                                                  ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[100],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Date: ${pcData['date']}',
                                                            ),
                                                            Text(
                                                              'Time: ${pcData['time']}',
                                                            ),
                                                            if (pcStatus !=
                                                                    'available' &&
                                                                pcData['issue'] !=
                                                                    null) ...[
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              const Text(
                                                                'User Issue:',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 6,
                                                              ),
                                                              Text(
                                                                '"${pcData['issue']}"',
                                                                style: const TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      if ((pcStatus ==
                                                              'maintenance') &&
                                                          role ==
                                                              'technician') ...[
                                                        Center(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              showStatusModal(
                                                                pcData['pc'] ??
                                                                    'Unknown',
                                                              );
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                            child: const Text(
                                                              'Change Status',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  )
                                                  : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
