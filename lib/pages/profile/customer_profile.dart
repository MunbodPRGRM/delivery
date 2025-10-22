import 'dart:convert';

import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/customer_address_get_res.dart';
import 'package:delivery_app/model/response/customer_login_post_res.dart';
import 'package:delivery_app/pages/auth/main_screen.dart';
import 'package:delivery_app/pages/home/customer_home.dart';
import 'package:delivery_app/pages/profile/add_address_map_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerProfile extends StatefulWidget {
  final User user;

  const CustomerProfile({super.key, required this.user});

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  final String baseUrl = "$API_ENDPOINT/upload/";

  final profileController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  List<Address> userAddresses = [];
  bool _isAddressLoading = true;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    phoneController.text = widget.user.phone;
    profileController.text =
        widget.user.profilePic ?? 'assets/images/avatar.png';

    // 5. เรียก API ดึงที่อยู่
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isAddressLoading = true;
    });

    try {
      final String userId = widget.user.id.toString();
      final String apiUrl = "$API_ENDPOINT/users/address?userId=$userId";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // แปลง JSON (List) ให้เป็น List<Address>
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          userAddresses = jsonList
              .map((json) => Address.fromJson(json))
              .toList();
          _isAddressLoading = false;
        });
      } else {
        setState(() {
          _isAddressLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถโหลดที่อยู่ได้')),
        );
      }
    } catch (e) {
      setState(() {
        _isAddressLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('การเชื่อมต่อล้มเหลว: $e')));
    }
  }

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
              // 6. แก้ไขการแสดงผลรูปภาพ
              // ถ้า profilePic เป็น path จาก server ให้ใช้ NetworkImage
              backgroundImage: widget.user.profilePic != null
                  ? NetworkImage("$baseUrl${widget.user.profilePic}")
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Address List',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 14),

            _buildAddressListWidget(),

            SizedBox(
              width: double.infinity,
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
                onPressed: add,
                child: const Text(
                  'เพิ่มที่อยู่',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // ✅ ให้แสดง label ทุกอัน
        currentIndex: 3, // อยู่หน้าแรก
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

  Widget _buildAddressListWidget() {
    if (_isAddressLoading) {
      // ถ้ากำลังโหลด
      return const Center(child: CircularProgressIndicator());
    }

    if (userAddresses.isEmpty) {
      // ถ้าไม่มีข้อมูล
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text('ยังไม่มีที่อยู่ที่บันทึกไว้'),
        ),
      );
    }

    // ถ้ามีข้อมูล ให้สร้าง ListView
    return ListView.builder(
      shrinkWrap:
          true, // ❗️สำคัญมาก เมื่อ ListView อยู่ใน SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // ❗️สำคัญมาก
      itemCount: userAddresses.length,
      itemBuilder: (context, index) {
        final address = userAddresses[index];

        // ใช้ชื่อสถานที่ (ที่อยู่บรรทัดแรก) เป็น Title
        String title = address.address.split(',')[0];

        return Card(
          elevation: 0,
          color: Colors.grey[100],
          margin: const EdgeInsets.symmetric(vertical: 4.0), // เพิ่มระยะห่าง
          child: ListTile(
            leading: Icon(Icons.location_on_outlined, color: Colors.blueAccent),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              address.address, // แสดงที่อยู่เต็ม
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // TODO: อนาคตสามารถทำหน้าแก้ไข/ลบที่อยู่ได้
            },
          ),
        );
      },
    );
  }

  void add() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressMapPage(user: widget.user),
      ),
    ).then((value) {
      // 9. ❗️❗️ สำคัญ! ❗️❗️
      // เมื่อเพิ่มที่อยู่ใหม่เสร็จ (และย้อนกลับมา)
      // ให้ดึงข้อมูลที่อยู่ใหม่ทันที
      _fetchAddresses();
    });
  }

  void Logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }
}
