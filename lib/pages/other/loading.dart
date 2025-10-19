import 'package:delivery_app/pages/auth/main_screen.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 10));

    // นำทางไปหน้า Onboarding หลังจากโหลดเสร็จ
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3532D7), // พื้นหลังสี #3532D7
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้หรือไอคอน
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.rocket_launch,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // ชื่อแอป
            const Text(
              'FastTrack',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
