import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    });

    try {
      String comlabName = _comlabController.text.trim();
      String pcName = _pcNameController.text.trim();
      String todayDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
      String todayTime = DateFormat('hh:mm a').format(DateTime.now());

      final comlabRef = FirebaseFirestore.instance.collection('comlab rooms').doc(comlabName);

      // 🔥 Ensure comlab document exists (even with dummy field if needed)
      await comlabRef.set({
        'created_at': FieldValue.serverTimestamp(), // ✅ or any useful field
      }, SetOptions(merge: true)); // Merge so we don't overwrite existing fields

      final pcRef = comlabRef.collection('PCs').doc(pcName);

      await pcRef.set({
        'date_reported': todayDate,
        'status': 'working',
        'time_reported': todayTime,
        'comlab': comlabName,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New PC created successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create PC: $e')),
      );
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
