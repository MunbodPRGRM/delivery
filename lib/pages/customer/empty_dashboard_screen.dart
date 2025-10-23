import 'package:delivery_app/model/response/customer_login_post_res.dart';
import 'package:delivery_app/pages/customer/upload_package_screen.dart';
import 'package:delivery_app/pages/home/customer_home.dart';
import 'package:delivery_app/pages/profile/customer_profile.dart';
import 'package:flutter/material.dart';

// หน้าจอ Dashboard 19 (Empty State)
class EmptyDashboardScreen extends StatefulWidget {
  final User user;

  const EmptyDashboardScreen({super.key, required this.user});

  @override
  State<EmptyDashboardScreen> createState() => _EmptyDashboardScreenState();
}

class _EmptyDashboardScreenState extends State<EmptyDashboardScreen> {
  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerHome(user: widget.user),
        ),
      );
    } else if (index == 1) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => ParcelDashboardScreen()),
      // );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmptyDashboardScreen(user: widget.user),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerProfile(user: widget.user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. ปุ่ม "สร้างรายการส่งพัสดุ"
              ElevatedButton(
                onPressed: () {
                  // Logic เมื่อกดปุ่ม
                  // นำทางไปยังหน้าอัปโหลดรูป (Dashboard 21)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UploadPackageScreen(user: widget.user),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A25E1), // สีม่วงเข้มจากภาพ
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'สร้างรายการส่งพัสดุ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 64),

              // 2. ไอคอนกล่องพัสดุ
              Icon(
                Icons
                    .inventory_2_outlined, // ไอคอนกล่อง (หรือใช้ SVG/Image ถ้ามี)
                size: 120,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 32),

              // 3. ข้อความอธิบาย
              Text(
                'You have not ordered any delivery yet. Would you like to change that today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),

      // 4. Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // ✅ ให้แสดง label ทุกอัน
        currentIndex: 2, // อยู่หน้าแรก
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'พัสดุของฉัน',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'ส่งพัสดุ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}
