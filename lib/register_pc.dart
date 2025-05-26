import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreatePCPage extends StatefulWidget {
  const CreatePCPage({super.key});

  @override
  State<CreatePCPage> createState() => _CreatePCPageState();
}

class _CreatePCPageState extends State<CreatePCPage> {
  final TextEditingController _pcNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? generatedLink;
  String? selectedComlab;
  List<Map<String, dynamic>> comlabList = [];

  final String staticImageUrl =
      "https://cdn.oneesports.gg/cdn-data/2024/08/HonorofKings_HOKInvitationalMidseason_grandfinals_LGDGaming_KPLDreamTeam-1536x864.jpg";

  @override
  void initState() {
    super.initState();
    selectedComlab = null;
    _loadComlabs();
  }

  Future<void> _loadComlabs() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('comlab rooms').get();
    setState(() {
      comlabList =
          snapshot.docs
              .map(
                (doc) => {'id': doc.id, 'name': doc['comlab_name'] ?? doc.id},
              )
              .toList();
    });
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedComlab == null || selectedComlab!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Computer Laboratory')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      generatedLink = null;
    });

    try {
      String comlabDocID = selectedComlab!;
      String inputPCName = _pcNameController.text.trim();

      final pcsCollection = FirebaseFirestore.instance
          .collection('comlab rooms')
          .doc(comlabDocID)
          .collection('PCs');

      final snapshot = await pcsCollection.get();
      int nextIndex = snapshot.docs.length + 1;
      String newDocID = 'PC $nextIndex';

      String todayDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
      String todayTime = DateFormat('hh:mm a').format(DateTime.now());
      String link = "https://comlab.com/pc?comlab=$comlabDocID&pc=$newDocID";

      await pcsCollection.doc(newDocID).set({
        'pc_name': inputPCName.isEmpty ? newDocID : inputPCName,
        'date_reported': todayDate,
        'status': 'available',
        'time_reported': todayTime,
        'comlab': comlabDocID,
        'generated_link': link,
        'last_issue': "",
      });

      if (!mounted) return;
      setState(() {
        generatedLink = link;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New PC created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create PC: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddComlabModal() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final scaffoldContext = context;
    bool modalLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> createComlab() async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }

              setStateDialog(() {
                modalLoading = true;
              });

              try {
                final snapshot =
                    await FirebaseFirestore.instance
                        .collection('comlab rooms')
                        .get();
                String nextDocID = 'comlab ${snapshot.docs.length + 1}';

                String imageUrl =
                    imageUrlController.text.trim().isEmpty
                        ? staticImageUrl
                        : imageUrlController.text.trim();

                await FirebaseFirestore.instance
                    .collection('comlab rooms')
                    .doc(nextDocID)
                    .set({
                      'comlab_name': nameController.text.trim(),
                      'image': imageUrl,
                      'created_at': FieldValue.serverTimestamp(),
                    });

                Navigator.of(context).pop();
                await _loadComlabs();

                if (mounted) {
                  setState(() {
                    selectedComlab = nextDocID;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New Comlab added successfully!'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  scaffoldContext,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                if (mounted) {
                  try {
                    setStateDialog(() {
                      modalLoading = false;
                    });
                  } catch (_) {}
                }
              }
            }

            return AlertDialog(
              title: const Text('Add New Comlab'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Comlab Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: imageUrlController,
                    onChanged: (_) => setStateDialog(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Image URL (optional)',
                      hintText: 'Leave blank to use default image',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Image Preview:'),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrlController.text.trim().isEmpty
                          ? staticImageUrl
                          : imageUrlController.text.trim(),
                      height: 100,
                      errorBuilder:
                          (_, __, ___) => const Text('Invalid image link'),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: modalLoading ? null : createComlab,
                  child:
                      modalLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _pcNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A48D7),
        title: const Text(
          'Create New PC',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDEAFF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Computer Laboratory',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: selectedComlab,
                items: [
                  ...comlabList.map(
                    (lab) => DropdownMenuItem(
                      value: lab['id'],
                      child: Text(lab['name']),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: 'add_new',
                    child: Text('➕ Add Comlab'),
                  ),
                ],
                onChanged: (value) {
                  if (value == 'add_new') {
                    _showAddComlabModal();
                  } else {
                    setState(() {
                      selectedComlab = value;
                    });
                  }
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please select a lab'
                            : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pcNameController,
                decoration: InputDecoration(
                  labelText: 'PC Name (optional)',
                  hintText: 'Auto create PC name if it is empty',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A48D7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: isLoading ? null : _submitData,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
