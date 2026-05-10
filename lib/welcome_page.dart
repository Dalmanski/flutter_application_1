import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

Future<String> storeDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();
  String deviceName = 'Unknown';
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    deviceName = androidInfo.model ?? 'Android';
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    deviceName = iosInfo.name ?? 'iOS';
  }
  return deviceName;
}

class _WelcomePageState extends State<WelcomePage> {
  String? selectedRole;

  void _handleGetStarted() async {
    if (selectedRole == "Student") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StudentLoginPage()),
      );
      return;
    }
    if (selectedRole == "Technician") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TechnicianLoginPage()),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a role first.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF7B61FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 20, top: 40),
                child: Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "I am a...",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRoleCard("Student", Icons.people_alt_outlined),
                const SizedBox(width: 20),
                _buildRoleCard("Technician", Icons.work_outline),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: selectedRole != null ? _handleGetStarted : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.deepPurple),
            const SizedBox(height: 15),
            Text(
              role,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});
  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  bool _isLoading = false;

  Future<void> _attemptStudentLogin() async {
    final email = _emailController.text.trim();
    final idNumber = _idController.text.trim();
    if (email.isEmpty || idNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill both Email and ID Number")),
      );
      return;
    }
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .where('idNumber', isEqualTo: idNumber)
              .where('role', isEqualTo: 'student')
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final accountId = doc.id;
        String deviceName = await storeDeviceName();
        await FirebaseFirestore.instance.collection('users').doc(accountId).set(
          {'loginOn': FieldValue.serverTimestamp(), 'deviceName': deviceName},
          SetOptions(merge: true),
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('account_id', accountId);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartHomeApp()),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => const StudentLoginErrorDialog(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.person_outline,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Student',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildPillField(
            controller: _emailController,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildPillField(
            controller: _idController,
            hint: 'ID Number',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: media.size.width * 0.6,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _attemptStudentLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 6,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('Log In', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFFBBA9FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.22,
                child: CustomPaint(painter: _CirclesPainter()),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final barricadeHeight = (min(width, height) * 0.08).clamp(
                40.0,
                140.0,
              );
              return Positioned(
                top: height * 0.28,
                left: 0,
                right: 0,
                height: barricadeHeight,
                child: CustomPaint(
                  painter: _BarricadePainter(
                    stripeWidth: max(
                      12,
                      (barricadeHeight * 0.35).roundToDouble(),
                    ),
                    rotation: -20,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.computer, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'LABSTAT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: card,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 2,
                        color: Colors.grey[200],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 10,
                          ),
                          child: Text(
                            'Go Back',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.9)),
        ),
      ),
    );
  }
}

class _BarricadePainter extends CustomPainter {
  final double stripeWidth;
  final double rotation;
  _BarricadePainter({required this.stripeWidth, this.rotation = -15});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final radians = rotation * pi / 180;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(radians);
    canvas.translate(-size.width / 2, -size.height / 2);
    final total = (size.width / stripeWidth).ceil() + 4;
    for (int i = -4; i < total; i++) {
      final dx = i * stripeWidth;
      final rect = Rect.fromLTWH(dx, 0, stripeWidth, size.height);
      paint.color = (i.isEven) ? const Color(0xFFFFD400) : Colors.black;
      canvas.drawRect(rect, paint);
    }
    canvas.restore();
    final fade =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.06)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fade);
  }

  @override
  bool shouldRepaint(covariant _BarricadePainter oldDelegate) =>
      oldDelegate.stripeWidth != stripeWidth ||
      oldDelegate.rotation != rotation;
}

class _CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = Colors.white.withOpacity(0.08);
    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.2),
        radius: 80,
      ),
      paint,
    );
    paint.color = Colors.white.withOpacity(0.06);
    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.25),
        radius: 110,
      ),
      paint,
    );
    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.55, size.height * 0.65),
        radius: 140,
      ),
      paint,
    );
    paint.color = Colors.white.withOpacity(0.04);
    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.8),
        radius: 100,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StudentLoginErrorDialog extends StatelessWidget {
  const StudentLoginErrorDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 120),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF6F4EFF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.person_outline, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 44,
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Error Occured',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You have entered an invalid ID Number.\nPlease check and try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB23B3B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    'Try again',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TechnicianLoginPage extends StatefulWidget {
  const TechnicianLoginPage({super.key});
  @override
  State<TechnicianLoginPage> createState() => _TechnicianLoginPageState();
}

class _TechnicianLoginPageState extends State<TechnicianLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _attemptLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields")),
      );
      return;
    }
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .where('role', isEqualTo: 'technician')
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final accountId = doc.id;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful")));
        String device = await storeDeviceName();
        await FirebaseFirestore.instance.collection('users').doc(accountId).set(
          {'loginOn': FieldValue.serverTimestamp(), 'deviceName': device},
          SetOptions(merge: true),
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('account_id', accountId);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartHomeApp()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B61FF), Color(0xFFBBA9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              "Welcome!",
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.work_outline,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Technician",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _usernameController,
                        icon: Icons.person,
                        hint: "Username",
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: _passwordController,
                        icon: Icons.vpn_key,
                        hint: "Password",
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _attemptLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 12,
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "Log In",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Go Back",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
        ),
      ),
    );
  }
}
