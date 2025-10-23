import 'dart:convert';

import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/customer_login_post_res.dart';
import 'package:delivery_app/model/response/delivery_info_get_res.dart';
import 'package:delivery_app/pages/customer/empty_dashboard_screen.dart';
import 'package:delivery_app/pages/home/customer_home.dart';
import 'package:delivery_app/pages/profile/customer_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. เปลี่ยนเป็น StatefulWidget
class Mypackage extends StatefulWidget {
  final User user;
  const Mypackage({super.key, required this.user});

  @override
  State<Mypackage> createState() => _MypackageState();
}

class _MypackageState extends State<Mypackage> {
  // 2. เพิ่มตัวแปร State สำหรับเก็บค่าแท็บ
  int selectedTab = 0; // 0 = จัดส่ง, 1 = ได้รับ
  bool _isLoading = true;
  List<DeliveryInfo> _sentList = [];
  List<DeliveryInfo> _receivedList = [];
  final String _baseUrl = "$API_ENDPOINT/uploads/"; // (สำหรับรูป Avatar)

  @override
  void initState() {
    super.initState();
    // 2. (เพิ่ม) เรียก API ทั้งสองส่วนเมื่อหน้าจอเริ่มทำงาน
    _fetchData();
  }

  // 3. (เพิ่ม) ฟังก์ชันดึงข้อมูลทั้งสองส่วน
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // ดึงทั้งสองอย่างพร้อมกัน
      await Future.wait([_fetchSentDeliveries(), _fetchReceivedDeliveries()]);
    } catch (e) {
      // (จัดการ Error)
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 4. (เพิ่ม) ฟังก์ชันดึง "รายการที่ส่ง"
  Future<void> _fetchSentDeliveries() async {
    final String userId = widget.user.id.toString();
    final String apiUrl = "$API_ENDPOINT/deliveries/sent?userId=$userId";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        _sentList = jsonList
            .map((json) => DeliveryInfo.fromJson(json))
            .toList();
      });
    } else {
      // (จัดการ Error)
    }
  }

  // 5. (เพิ่ม) ฟังก์ชันดึง "รายการที่ได้รับ"
  Future<void> _fetchReceivedDeliveries() async {
    final String userId = widget.user.id.toString();
    final String apiUrl = "$API_ENDPOINT/deliveries/received?userId=$userId";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        _receivedList = jsonList
            .map((json) => DeliveryInfo.fromJson(json))
            .toList();
      });
    } else {
      // (จัดการ Error)
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
      backgroundColor: const Color(0xFFFDFDFD),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            // ทักทายผู้ใช้
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.user.profilePic != null
                      ? NetworkImage("$_baseUrl${widget.user.profilePic}")
                      : const AssetImage('assets/images/avatar.png')
                            as ImageProvider,
                ),
                SizedBox(width: 12),
                Text(
                  'สวัสดี, ${widget.user.name}', // ⬅️ ใช้ข้อมูลจริง
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 24),

            // 3. แท็บที่คัดลอกมา
            Row(
              children: [
                _buildTabItem(0, 'รายการพัสดุที่จัดส่ง'),
                _buildTabItem(1, 'รายการพัสดุที่ได้รับ'),
              ],
            ),
            SizedBox(height: 16), // เพิ่มระยะห่าง
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
            SizedBox(height: 16), // เพิ่มระยะห่าง
            // 4. ส่วนแสดงผลตามแท็บที่เลือก
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : selectedTab == 0
                  ? _buildSentParcelList()
                  : _buildReceivedParcelList(),
            ),
          ],
        ),
      ),

      // แถบเมนูด้านล่าง
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // ✅ ให้แสดง label ทุกอัน
        currentIndex: 1, // อยู่หน้าแรก
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

  Widget _buildTabItem(int index, String title) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue[900] : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // สร้าง Widget สำหรับแสดงเนื้อหาของแท็บ "จัดส่ง"
  Widget _buildSentParcelList() {
    if (_sentList.isEmpty) {
      return Center(child: Text('คุณยังไม่มีรายการที่ส่ง'));
    }

    return ListView.builder(
      itemCount: _sentList.length,
      itemBuilder: (context, index) {
        final item = _sentList[index];
        return _buildDeliveryCard(
          description: item.itemDescription ?? 'พัสดุ',
          status: item.getStatusText(),
          personInfo: 'ถึง: ${item.receiverName}', // ⬅️ แสดงชื่อผู้รับ
          statusColor: Colors.blue,
        );
      },
    );
  }

  // สร้าง Widget สำหรับแสดงเนื้อหาของแท็บ "ได้รับ"
  Widget _buildReceivedParcelList() {
    if (_receivedList.isEmpty) {
      return Center(child: Text('คุณยังไม่มีรายการที่จะได้รับ'));
    }

    return ListView.builder(
      itemCount: _receivedList.length,
      itemBuilder: (context, index) {
        final item = _receivedList[index];
        return _buildDeliveryCard(
          description: item.itemDescription ?? 'พัสดุ',
          status: item.getStatusText(),
          personInfo: 'จาก: ${item.senderName}', // ⬅️ แสดงชื่อผู้ส่ง
          statusColor: Colors.green,
        );
      },
    );
  }

  Widget _buildDeliveryCard({
    required String description,
    required String status,
    required String personInfo,
    required Color statusColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.inventory_2_outlined, color: statusColor),
        ),
        title: Text(description, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(personInfo),
        trailing: Text(
          status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          // TODO: กดเพื่อไปหน้าดูรายละเอียด (หน้าที่มี Real-time tracking)
        },
      ),
    );
  }
}
