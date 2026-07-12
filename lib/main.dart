import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Another Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2962ff)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- INITIAL LOG IN SCREEN ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBg = Color(0xff0a1931); 
    const Color inputFieldBg = Color(0xff15305b);
    const Color accentBlue = Color(0xff2962ff);

    return Scaffold(
      backgroundColor: primaryDarkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ANOTHER HOME',
                  style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Welcome Back',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'serif', fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputFieldLabel('UOM-MAIL'),
                      _buildCustomTextField(Icons.mail_outline, 'p12345@siswa.um.edu.my', inputFieldBg),
                      const SizedBox(height: 20),

                      _buildInputFieldLabel('PASSWORD'),
                      _buildCustomTextField(Icons.lock_outline, 'Enter your password', inputFieldBg, suffixIcon: Icons.visibility_off_outlined),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentDashboard()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.login_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(labelText, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildCustomTextField(IconData prefixIcon, String hintText, Color fieldBg, {IconData? suffixIcon}) {
    return Container(
      height: 54,
      decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(prefixIcon, color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(hintText: hintText, hintStyle: const TextStyle(color: Colors.white24), border: InputBorder.none),
            ),
          ),
          if (suffixIcon != null) ...[Icon(suffixIcon, color: Colors.white38, size: 20)]
        ],
      ),
    );
  }
}

// --- REGISTER SCREEN ---
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBg = Color(0xff0a1931); 
    const Color inputFieldBg = Color(0xff15305b);
    const Color accentBlue = Color(0xff2962ff);

    return Scaffold(
      backgroundColor: primaryDarkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'ANOTHER HOME',
                style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create your account',
                style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'serif', fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputFieldLabel('FULL NAME'),
                    _buildCustomTextField(Icons.person_outline, 'Ahmad Razin Abdullah', inputFieldBg),
                    const SizedBox(height: 20),

                    _buildInputFieldLabel('UOM-MAIL'),
                    _buildCustomTextField(Icons.mail_outline, 'p12345@siswa.um.edu.my', inputFieldBg),
                    const SizedBox(height: 20),

                    _buildInputFieldLabel('MOBILE NUMBER'),
                    _buildCustomTextField(Icons.phone_outlined, '+60 12-345 6789', inputFieldBg),
                    const SizedBox(height: 20),

                    _buildInputFieldLabel('PASSWORD'),
                    _buildCustomTextField(Icons.lock_outline, 'Min. 8 characters', inputFieldBg, suffixIcon: Icons.visibility_off_outlined),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const StudentDashboard()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(labelText, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildCustomTextField(IconData prefixIcon, String hintText, Color fieldBg, {IconData? suffixIcon}) {
    return Container(
      height: 54,
      decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(prefixIcon, color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(hintText: hintText, hintStyle: const TextStyle(color: Colors.white24), border: InputBorder.none),
            ),
          ),
          if (suffixIcon != null) ...[Icon(suffixIcon, color: Colors.white38, size: 20)]
        ],
      ),
    );
  }
}

// --- STUDENT HOME DASHBOARD SCREEN ---
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb), 
      appBar: AppBar(
        backgroundColor: const Color(0xff2962ff),
        elevation: 0,
        title: const Text('ANOTHER HOME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Profile Card
            Card(
              elevation: 0,
              color: const Color(0xffe3f2fd),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xff2962ff),
                    radius: 24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text('Welcome, Amal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                  subtitle: Text('Room: 1-A', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Maintenance / Complaint Status Widget Tracker
            const Text('Active Requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 0.3)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xfffff9db), 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xfff59f00).withOpacity(0.2), width: 1.5),
              ),
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.water_drop_outlined, color: Color(0xfff59f00), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Water Leakage Fix',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff5c3e00)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Room 1-A • Assigned to Plumber',
                          style: TextStyle(fontSize: 12, color: const Color(0xff5c3e00).withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xfff59f00).withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync, size: 12, color: Color(0xfff59f00)),
                        SizedBox(width: 4),
                        Text(
                          'In Progress',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xfff59f00)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 28),
            const Text('Quick actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 0.3)),
            const SizedBox(height: 16),

            // Navigation Actions Grid Grid
            GridView.count(
              crossAxisCount: 3, 
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              children: [
                _buildModernActionCard(context, Icons.king_bed_outlined, 'Room', const Color(0xffedf2fe), const Color(0xff2962ff), const MyRoomScreen()),
                _buildModernActionCard(context, Icons.credit_card_outlined, 'Payment', const Color(0xffe8f8f0), const Color(0xff0fad56), const PaymentScreen()),
                _buildModernActionCard(context, Icons.assignment_ind_outlined, 'Visitor', const Color(0xfffef3e7), const Color(0xfff2994a), const VisitorScreen()),
                _buildModernActionCard(context, Icons.build_outlined, 'Maintenance', const Color(0xfffff9db), const Color(0xfff59f00), const ComplaintScreen()),
                _buildModernActionCard(context, Icons.notifications_none_outlined, 'Notice', const Color(0xfff8f0fb), const Color(0xffa142f4), const NoticesScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionCard(BuildContext context, IconData icon, String title, Color containerBg, Color iconColor, Widget? destination) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title details coming next!')),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: containerBg, 
                  borderRadius: BorderRadius.circular(22), 
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 28, color: iconColor), 
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xff4a5568)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- REDESIGNED PREMIUM ROOM VIEW ---
class MyRoomScreen extends StatelessWidget {
  const MyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: const Color(0xff2962ff),
        elevation: 0,
        title: const Text('My Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xffe3f2fd),
                      child: const Icon(Icons.hotel, size: 64, color: Color(0xff2962ff)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xffedf2fe),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xff2962ff).withOpacity(0.12), width: 1),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xff2962ff), size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Room Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff0a1931), letterSpacing: 0.2),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.black12, thickness: 0.8),
                  ),
                  _buildRoomDetailRow('Hostel', 'Hostel A'),
                  _buildRoomDetailRow('Block', 'Block B - Second floor'),
                  _buildRoomDetailRow('Room Number', '1-A'),
                  _buildRoomDetailRow('Bed Number', 'Bed 1'),
                  _buildRoomDetailRow('Room Type', 'Double Occupancy'),
                  _buildRoomDetailRow('Allocation Date', '01/03/2024'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff4a5568)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff0a1931)),
          ),
        ],
      ),
    );
  }
}

// --- NEW NOTICES VIEW (Matching Your Blue Style) ---
class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: const Color(0xff2962ff),
        elevation: 0,
        title: const Text('Notices', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildNoticeItem('Urgent', Colors.red, 'Water Supply Interruption — July 3', 'Maintenance work on the main tank will interrupt water supply from 6 AM to 2 PM on Thursday, July 3rd.', '01 Jul 2026'),
          _buildNoticeItem('General', Colors.blue, 'End-of-Semester Room Inspection', 'Room inspections are scheduled for July 8–10. All residents must ensure their rooms meet setup guidelines.', '30 Jun 2026'),
          _buildNoticeItem('Event', Colors.purple, 'Cultural Night — Hostel Fest 2026', 'Join us for an evening of performances, food stalls, and music at the Hostel Courtyard on July 15th.', '28 Jun 2026'),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String category, Color categoryColor, String title, String body, String date) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(category, style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                Text(date, style: const TextStyle(color: Colors.black38, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff0a1931))),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// --- NEW PAYMENT VIEW ---
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: const Color(0xff2962ff),
        elevation: 0,
        title: const Text('Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('June payment 2026', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Rs. 7500', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Pay now', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Payment History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.2))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('May payment 2026', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 2),
                      Text('Paid on 20 May 2026', style: TextStyle(color: Colors.black45, fontSize: 12)),
                    ],
                  ),
                  Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- UPDATED COMPLAINT SUBMISSION VIEW ---
class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff2962ff),
        title: const Text('Maintenance and Complaints', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter title',
                filled: true,
                fillColor: const Color(0xfff1f3f9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Describe Your Problem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Provide details about what needs fixing...',
                filled: true,
                fillColor: const Color(0xfff1f3f9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xfff1f3f9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12, width: 1.5),
              ),
              child: const Column(
                children: [
                  Icon(Icons.camera_alt_outlined, size: 32, color: Colors.black38),
                  SizedBox(height: 8),
                  Text('Attach Picture', style: TextStyle(color: Colors.black45, fontSize: 13)),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.green, content: Text('Complaint submitted successfully!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2962ff),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
// --- VISITOR MODULE ---
class VisitorScreen extends StatelessWidget {
  const VisitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff2962ff),
        title: const Text('Add New Visitor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visitor Full Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter guest name',
                filled: true,
                fillColor: const Color(0xfff1f3f9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('NIC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter guest identification number',
                filled: true,
                fillColor: const Color(0xfff1f3f9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Visit Purpose', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfff1f3f9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              hint: const Text('Select purpose'),
              items: ['Family Visit', 'Group Study', 'Delivery / Logistics']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.green, content: Text('Visitor pass entry registered successfully.')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2962ff),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}