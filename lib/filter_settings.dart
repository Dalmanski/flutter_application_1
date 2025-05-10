import 'package:flutter/material.dart';

class FilterSettingsPage extends StatelessWidget {
  final String mode;

  const FilterSettingsPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE6FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: const BoxDecoration(
                color: Color(0xFF7B61FF),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    mode == 'faq' ? "FAQ" : "Contact Us",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (mode == 'faq')
              Expanded(child: _buildFAQContent())
            else
              _buildContactContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQContent() {
    final faqItems = [
      {
        "question": "What is this app for?",
        "answerSpans": [
          TextSpan(text: "Compstat is a "),
          TextSpan(
            text: "PC status tracker",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " and "),
          TextSpan(
            text: "reporter app",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ". It shows users which PCs are "),
          TextSpan(
            text: "available",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " for use and allows them to "),
          TextSpan(
            text: "report faulty units",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " for technicians to address."),
        ],
      },
      {
        "question": "How do I report a faulty PC?",
        "answerSpans": [
          TextSpan(text: "Tap the "),
          TextSpan(
            text: "QR Code button",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                " in the bottom navigation bar to open your camera. Then, scan the ",
          ),
          TextSpan(
            text: "QR code",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " on the PC you want to report."),
        ],
      },
      {
        "question": "How do I sign up for a technician account?",
        "answerSpans": [
          TextSpan(
            text: "Technician roles",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " are assigned by the app developers. Users "),
          TextSpan(
            text: "cannot register as technicians",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " on their own."),
        ],
      },
      {
        "question": "Can I track the status of my reports?",
        "answerSpans": [
          TextSpan(text: "Yes. After reporting a PC, go to the corresponding "),
          TextSpan(
            text: "computer lab",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " and tap the "),
          TextSpan(
            text: "\"Maintenance\"",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: " button. You'll see a list of all PCs in that lab with ",
          ),
          TextSpan(
            text: "active maintenance tickets",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: "."),
        ],
      },
      {
        "question": "Can I change the status of a PC?",
        "answerSpans": [
          TextSpan(text: "No. Only "),
          TextSpan(
            text: "technicians",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " have permission to "),
          TextSpan(
            text: "update the status",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " of PCs with maintenance tickets."),
        ],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqItems.length,
      itemBuilder: (context, index) {
        final item = faqItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              item['question'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B61FF),
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    children: (item['answerSpans'] as List<TextSpan>),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent full height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Need help?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B61FF),
              ),
            ),
            SizedBox(height: 10),
            Text("Email us at:", style: TextStyle(fontSize: 16)),
            Text(
              "support@schoolpcapp.com",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Or contact your school technician for direct assistance.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
