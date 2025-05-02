import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreatePCPage extends StatefulWidget {
  const CreatePCPage({super.key});

  @override
  State<CreatePCPage> createState() => _CreatePCPageState();
}

class _CreatePCPageState extends State<CreatePCPage> {
  final TextEditingController _comlabController = TextEditingController();
  final TextEditingController _pcNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? generatedLink; // 🌟 To store the generated link after submit

  @override
  void dispose() {
    _comlabController.dispose();
    _pcNameController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      generatedLink = null;
    });

    try {
      String comlabName = _comlabController.text.trim();
      String pcName = _pcNameController.text.trim();
      String todayDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
      String todayTime = DateFormat('hh:mm a').format(DateTime.now());

      final comlabRef = FirebaseFirestore.instance
          .collection('comlab rooms')
          .doc(comlabName);

      await comlabRef.set({
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final pcRef = comlabRef.collection('PCs').doc(pcName);

      // 🔥 Encode names before making the link
      String encodedComlab = Uri.encodeComponent(comlabName);
      String encodedPC = Uri.encodeComponent(pcName);

      String link = "https://comlab.com/pc?comlab=$encodedComlab&pc=$encodedPC";

      // 🌟 Save all PC info including the link
      await pcRef.set({
        'date_reported': todayDate,
        'status': 'working',
        'time_reported': todayTime,
        'comlab': comlabName,
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
              TextFormField(
                controller: _comlabController,
                decoration: InputDecoration(
                  labelText: 'Computer Laboratory Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Computer Laboratory Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pcNameController,
                decoration: InputDecoration(
                  labelText: 'PC Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PC Name';
                  }
                  return null;
                },
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
                        : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
              const SizedBox(height: 30),
              if (generatedLink != null) ...[
                const Text(
                  'Generated QR Code:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Center(
                  child: QrImageView(
                    data: generatedLink!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
