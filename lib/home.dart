import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'filtered_status.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Map<String, dynamic>> comlabs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComlabs();
  }

  Future<void> fetchComlabs() async {
    try {
      final QuerySnapshot roomsSnapshot =
          await FirebaseFirestore.instance.collection('comlab rooms').get();

      List<Map<String, dynamic>> fetchedComlabs = [];

      for (var roomDoc in roomsSnapshot.docs) {
        final roomName = roomDoc.id;
        final roomData = roomDoc.data() as Map<String, dynamic>;
        final imageUrl = roomData['image'] ?? '';

        final pcsSnapshot =
            await FirebaseFirestore.instance
                .collection('comlab rooms')
                .doc(roomName)
                .collection('PCs')
                .get();

        int totalPCs = pcsSnapshot.docs.length;
        int workingPCs =
            pcsSnapshot.docs
                .where(
                  (doc) =>
                      (doc['status'] ?? '').toString().toLowerCase() ==
                      'available',
                )
                .length;

        double occupied = totalPCs == 0 ? 0 : workingPCs / totalPCs;

        fetchedComlabs.add({
          'name': roomName,
          'occupied': occupied,
          'image': imageUrl,
        });
      }

      setState(() {
        comlabs = fetchedComlabs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching comlabs: $e");
    }
  }

  void showLabDetail(BuildContext context, Map<String, dynamic> lab) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        _capitalize(lab['name']),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A48D7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Hero(
                            tag: lab['name'],
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  lab['image'] ?? '',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress,
                                  ) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                        ),
                                      );
                                    }
                                  },
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        size: 60,
                                      ),
                                ),
                              ),
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
                                    value: lab['occupied'],
                                    strokeWidth: 20,
                                    backgroundColor: Colors.white,
                                    color: const Color(0xFF6A48D7),
                                  ),
                                ),
                                Container(
                                  height: 90,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(lab['occupied'] * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF6A48D7),
                                      ),
                                    ),
                                    const Text(
                                      'Available Units',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FilteredStatusPage(
                                        status: 'available',
                                        labName: lab['name'],
                                      ),
                                ),
                              );
                            },
                            child: _statusBox(
                              label: "Available",
                              icon: Icons.check,
                              color: Colors.green,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FilteredStatusPage(
                                        status: 'maintenance',
                                        labName: lab['name'],
                                      ),
                                ),
                              );
                            },
                            child: _statusBox(
                              label: "Maintenance",
                              icon: Icons.build,
                              color: Colors.orange,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FilteredStatusPage(
                                        status: 'unresolved',
                                        labName: lab['name'],
                                      ),
                                ),
                              );
                            },
                            child: _statusBox(
                              label: "Unresolved",
                              icon: Icons.warning,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBox({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ],
    );
  }

  String _capitalize(String name) {
    return name.isEmpty
        ? name
        : name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            'https://img.freepik.com/free-vector/simple-blue-gradient-background-vector-business_53876-166894.jpg?t=st=1746084723~exp=1746088323~hmac=5bbe55fc1d8f10b27adf454c8924c6557cd467f461786ff874c64d045553011a&w=740',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            margin: const EdgeInsets.only(
              top: 17,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child:
                isLoading
                    ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    )
                    : comlabs.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No Comlabs Found'),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      itemCount: comlabs.length,
                      itemBuilder: (context, index) {
                        final lab = comlabs[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => showLabDetail(context, lab),
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _capitalize(lab['name']),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6A48D7),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Hero(
                                      tag: lab['name'],
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            lab['image'] ?? '',
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (
                                              BuildContext context,
                                              Widget child,
                                              ImageChunkEvent? loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                (loadingProgress
                                                                        .expectedTotalBytes ??
                                                                    1)
                                                            : null,
                                                  ),
                                                );
                                              }
                                            },
                                            errorBuilder:
                                                (_, __, ___) => const Icon(
                                                  Icons.broken_image,
                                                  size: 60,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (index < comlabs.length - 1) const Divider(),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }
}
