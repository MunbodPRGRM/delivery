import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/rider_login_post_res.dart';
import 'package:delivery_app/pages/auth/main_screen.dart';
import 'package:delivery_app/pages/home/rider_home.dart';
import 'package:flutter/material.dart';

class RiderProfile extends StatefulWidget {
  final Rider rider;

  const RiderProfile({super.key, required this.rider});

  @override
  State<RiderProfile> createState() => _RiderProfileState();
}

class _RiderProfileState extends State<RiderProfile> {
  final String baseUrl = "$API_ENDPOINT/uploads/";

  final profileController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final caridController = TextEditingController();
  final carpictureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลจาก widget.rider มาใส่ใน Controller
    nameController.text = widget.rider.name;
    phoneController.text = widget.rider.phone;

    // (สันนิษฐานว่า Model ของคุณมีตัวแปร .plateNumber, .profilePic, .vehiclePic)
    caridController.text = widget.rider.plateNumber ?? 'N/A';

    // เก็บ path รูปไว้ (เผื่อใช้ แต่เราจะใช้ widget.rider.profilePic โดยตรง)
    profileController.text =
        widget.rider.profilePic ?? 'assets/images/avatar.png';
    carpictureController.text =
        widget.rider.vehiclePic ?? 'assets/images/avatar.png';
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RiderHome(rider: widget.rider)),
      );
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
    }
  }

  Widget buildDisplayField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label อยู่ข้างนอก
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // TextField
          TextField(
            controller: controller,
            enabled: false,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3532D7), // สีพื้นหลัง
                  foregroundColor: Colors.white, // สีตัวอักษร
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onPressed: Logout,
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundImage: widget.rider.profilePic != null
                  ? NetworkImage("$baseUrl${widget.rider.profilePic}")
                  : const AssetImage('assets/images/avatar.png')
                        as ImageProvider,
            ),
            SizedBox(height: 14),

            buildDisplayField(
              icon: Icons.person,
              label: 'Person',
              controller: nameController,
            ),
            buildDisplayField(
              icon: Icons.phone,
              label: 'Mobile Number',
              controller: phoneController,
            ),

            const SizedBox(height: 28),

            // ช่องแสดงรูปภาพ
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: widget.rider.vehiclePic != null
                              ? NetworkImage(
                                  "$baseUrl${widget.rider.vehiclePic}",
                                )
                              : const AssetImage('assets/images/avatar.png')
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            buildDisplayField(
              icon: Icons.motorcycle,
              label: 'License plate',
              controller: caridController,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // ✅ ให้แสดง label ทุกอัน
        currentIndex: 2, // อยู่หน้าแรก
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

  void Logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }
}
