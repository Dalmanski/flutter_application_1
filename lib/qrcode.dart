// ✅ Full corrected version below
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrLink = '';
  Map<String, dynamic>? pcData;
  final TextEditingController issueController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    controller?.dispose();
    issueController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      setState(() {
        qrLink = scanData.code ?? '';
        isLoading = true;
      });
      await fetchPCData(qrLink);
    });
  }

  Future<void> fetchPCData(String urlString) async {
    try {
      if (!urlString.contains('comlab.com') ||
          !urlString.contains('comlab=') ||
          !urlString.contains('pc=')) {
        _showInvalidQRDialog("Invalid QR format");
        return;
      }

      final comlabStart = urlString.indexOf('comlab=') + 7;
      final pcStart = urlString.indexOf('pc=');

      String comlab = '';
      String pc = '';

      if (comlabStart > 6 && pcStart > 0) {
        comlab = urlString.substring(
          comlabStart,
          urlString.indexOf('&', comlabStart),
        );
        pc = urlString.substring(pcStart + 3);

        comlab = Uri.decodeComponent(comlab);
        pc = Uri.decodeComponent(pc);
      }

      if (comlab.isNotEmpty && pc.isNotEmpty) {
        setState(() {
          pcData = {'comlabId': comlab, 'pcId': pc};
        });

        await checkPCInFirestore(comlab, pc);
      } else {
        _showInvalidQRDialog("Empty comlab or pc value");
      }
    } catch (e) {
      _showInvalidQRDialog("Exception: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> checkPCInFirestore(String comlabDocId, String pcDocId) async {
    try {
      final comlabDoc =
          await FirebaseFirestore.instance
              .collection('comlab rooms')
              .doc(comlabDocId)
              .get();

      if (!comlabDoc.exists) {
        _showUnknownPCDialog(pcDocId, comlabDocId);
        return;
      }

      final comlabName = comlabDoc.data()?['comlab_name'] ?? comlabDocId;

      final pcDoc =
          await FirebaseFirestore.instance
              .collection('comlab rooms')
              .doc(comlabDocId)
              .collection('PCs')
              .doc(pcDocId)
              .get();

      if (!pcDoc.exists) {
        _showUnknownPCDialog(pcDocId, comlabName);
        return;
      }

      final pcName = pcDoc.data()?['pc_name'] ?? pcDocId;
      final status = pcDoc.data()?['status'] ?? 'working';

      setState(() {
        pcData = {
          'comlabId': comlabDocId,
          'pcId': pcDocId,
          'lab': comlabName,
          'pc': pcName,
          'status': status,
        };
      });

      _showComputerStatusModal();
    } catch (e) {
      _showUnknownPCDialog(pcDocId, comlabDocId);
    }
  }

  void _showInvalidQRDialog([String? error]) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Invalid QR Code"),
            content: Text(error ?? "Not a correct QR code, try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller?.resumeCamera();
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showUnknownPCDialog(String pcName, String comlabName) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Unknown PC"),
            content: Text("PC Name: $pcName\nComlab: $comlabName"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller?.resumeCamera();
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showComputerStatusModal() {
    if (!mounted) return;
    issueController.clear();

    final status = pcData?["status"] ?? "working";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7754CC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white),
                        Text(
                          pcData?["lab"] ?? 'Laboratory',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            controller?.resumeCamera();
                          },
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    status == "maintenance" ? Icons.warning : Icons.error,
                    color: status == "maintenance" ? Colors.orange : Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Computer:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(pcData?["pc"] ?? 'Unknown PC'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status == "available"
                            ? "Working"
                            : status.toUpperCase(),
                        style: TextStyle(
                          color:
                              (status == "maintenance" ||
                                      status == "unresolved")
                                  ? Colors.red
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (status == "maintenance" || status == "unresolved")
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Sorry for the inconvenience. Please use another computer.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'REPORT AN ISSUE:',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: issueController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue you encountered...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final issueText = issueController.text.trim();
                          if (issueText.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please describe the issue.'),
                                ),
                              );
                            }
                            return;
                          }

                          Navigator.of(context).pop();
                          controller?.resumeCamera();

                          await updatePCStatusAndLogTicket(
                            pcData?["comlabId"],
                            pcData?["pcId"],
                            pcData?["lab"],
                            pcData?["pc"],
                            issueText,
                          );
                        },
                        child: const Text(
                          'Submit Ticket',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> updatePCStatusAndLogTicket(
    String? comlabDocId,
    String? pcDocId,
    String? comlabName,
    String? pcName,
    String issueDescription,
  ) async {
    final now = DateTime.now();
    final timeFormatted = DateFormat('hh:mm a').format(now);
    final dateFormatted = DateFormat('MMMM d, yyyy').format(DateTime.now());

    try {
      await FirebaseFirestore.instance
          .collection('comlab rooms')
          .doc(comlabDocId)
          .collection('PCs')
          .doc(pcDocId)
          .update({
            'status': 'maintenance',
            'last_issue': issueDescription,
            'time_reported': timeFormatted,
            'date_reported': dateFormatted,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Your $pcName on $comlabName is now on maintenance."),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to submit ticket: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              overlayColor: const Color.fromARGB(182, 0, 0, 0),
              borderColor: Colors.white,
              borderRadius: 12,
              borderLength: 50,
              borderWidth: 8,
              cutOutSize: 250,
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
