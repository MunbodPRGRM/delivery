import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/rider_login_post_res.dart';
import 'package:delivery_app/pages/profile/rider_profile.dart';
import 'package:flutter/material.dart';

class RiderHome extends StatefulWidget {
  final Rider rider;

  const RiderHome({super.key, required this.rider});

  @override
  State<RiderHome> createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> {
  final String baseUrl = "$API_ENDPOINT/upload/";

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      // อยู่หน้าแรกแล้ว
    } else if (index == 1) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => ParcelDashboardScreen()),
      // );
    } else if (index == 2) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => SendParcelScreen()),
      // );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RiderProfile(rider: widget.rider),
        ),
      );
    } else if (index == 3) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => RiderProfile(rider: widget.rider),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ทักทายผู้ใช้
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.rider.profilePic != null
                      ? NetworkImage("$baseUrl${widget.rider.profilePic}")
                      : const AssetImage('assets/images/avatar.png')
                            as ImageProvider,
                ),
                SizedBox(width: 12),
                Text(
                  'สวัสดี, ${widget.rider.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 24),

            // ช่องค้นหาสถานะพัสดุ
            TextField(
              decoration: InputDecoration(
                hintText: 'ตรวจสอบสถานะพัสดุ',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),

      // แถบเมนูด้านล่าง
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // ✅ ให้แสดง label ทุกอัน
        currentIndex: 0, // อยู่หน้าแรก
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'รับงาน'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}
