import 'dart:io';
import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/customer_address_get_res.dart';
import 'package:delivery_app/model/response/customer_login_post_res.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// เปลี่ยนเป็น StatefulWidget เพื่อจัดการรายการพัสดุ
class ConfirmationScreen extends StatefulWidget {
  final User senderUser;
  final Address senderAddress;
  final User receiverUser;
  final Address receiverAddress;
  final String itemDescription;
  final XFile imageFile;

  const ConfirmationScreen({
    super.key,
    required this.senderUser,
    required this.senderAddress,
    required this.receiverUser,
    required this.receiverAddress,
    required this.itemDescription,
    required this.imageFile,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _isLoading = false;
  // URL รูปจำลอง
  final String _simulatedPackageImageUrl =
      'https://placehold.co/100x80/e8e0ff/4A25E1?text=Package';

  // รายการพัสดุ (เริ่มต้นด้วย 1 รายการ)
  final List<Map<String, String>> _packages = [
    {'title': 'Package 1', 'destination': 'Destination'},
  ];

  // ฟังก์ชันสำหรับเพิ่มพัสดุ
  void _addPackage() {
    if (_packages.length < 5) {
      setState(() {
        _packages.add({
          'title': 'Package ${_packages.length + 1}',
          'destination': 'Destination',
        });
      });
      print('Package added! Total packages: ${_packages.length}');
    } else {
      // TODO: แสดงข้อความแจ้งเตือนว่าเพิ่มได้สูงสุด 5 ชิ้น
      print('Cannot add more than 5 packages.');
      //
      // ในแอปจริง อาจใช้ SnackBar
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('You can only add up to 5 packages.'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  Future<void> _confirmOrderOnServer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. ⭐️ สร้าง Multipart Request
      final String apiUrl = "$API_ENDPOINT/deliveries";
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // 4. ⭐️ เพิ่มข้อมูล Text (Fields)
      request.fields['senderId'] = widget.senderUser.id.toString();
      request.fields['receiverId'] = widget.receiverUser.id.toString();
      request.fields['receiverAddressId'] = widget.receiverAddress.id
          .toString();
      request.fields['itemDescription'] = widget.itemDescription;

      // 5. ⭐️ เพิ่มไฟล์ (File)
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo_status1', // ❗️ ชื่อนี้ต้องตรงกับที่ Multer ใน Node.js ตั้งไว้
          widget.imageFile.path,
        ),
      );

      // 6. ⭐️ ส่ง Request
      var response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        // 7. ⭐️ ถ้าสำเร็จ
        print('สร้างออเดอร์สำเร็จ!');
        // TODO: แสดงหน้าจอว่าสำเร็จ แล้วเด้งกลับไปหน้า Home
        // Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        // 8. ⭐️ ถ้าล้มเหลว
        final respBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $respBody')));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('การเชื่อมต่อล้มเหลว: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // พื้นหลังสีเทาอ่อน
      appBar: AppBar(
        backgroundColor: Colors.white, // พื้นหลัง AppBar สีขาว
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Delivery',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              // --- ตรวจสอบจำนวนพัสดุเพื่อเลือกว่าจะแสดงผลแบบไหน ---
              child: _packages.length == 1
                  ? _buildSinglePackageView(
                      context,
                    ) // <== แสดงผลแบบ Dashboard 26
                  : _buildMultiPackageView(
                      context,
                    ), // <== แสดงผลแบบ Dashboard 27
            ),
          ),

          // --- ส่วนล่างสุด (ปุ่มยืนยัน) ---
          // (แยกออกมาเป็น Widget เพื่อใช้ร่วมกัน)
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // --- Widget สำหรับแสดงผลแบบ Dashboard 26 (พัสดุชิ้นเดียว) ---
  Widget _buildSinglePackageView(BuildContext context) {
    // นี่คือ Layout จากภาพ Dashboard 26 (image_37971e.png)
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปภาพพัสดุ (ใหญ่)
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(
                File(widget.imageFile.path), // ⬅️ ใช้รูปจริง
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Delivery Details ---
          const Text(
            'Delivery Details', // (ลบเลข ID จำลองออก)
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // 14. ⭐️ แสดงข้อมูลจริง
          _buildInfoRow(
            Icons.gps_fixed,
            widget.senderAddress.address, // ⬅️ ที่อยู่ผู้ส่ง
            const Color(0xFF4A25E1),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            widget.receiverAddress.address, // ⬅️ ที่อยู่ผู้รับ
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.description_outlined,
            widget.itemDescription, // ⬅️ รายละเอียด
            Colors.grey[700]!,
          ),

          const Divider(height: 40),

          // --- Sender ---
          _buildSectionTitle('Sender'),
          _buildInfoRow(
            Icons.person_outline,
            widget.senderUser.name, // ⬅️ ชื่อผู้ส่ง
            Colors.grey[700]!,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.phone_outlined,
            widget.senderUser.phone, // ⬅️ เบอร์ผู้ส่ง
            Colors.grey[700]!,
          ),

          const Divider(height: 40),

          // --- Receiver ---
          _buildSectionTitle('Receiver'),
          _buildInfoRow(
            Icons.person_outline,
            widget.receiverUser.name, // ⬅️ ชื่อผู้รับ
            Colors.grey[700]!,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.phone_outlined,
            widget.receiverUser.phone, // ⬅️ เบอร์ผู้รับ
            Colors.grey[700]!,
          ),

          const Divider(height: 40),

          // --- Add Another Package ---
          _buildAddPackageRow(context),
        ],
      ),
    );
  }

  // --- Widget สำหรับแสดงผลแบบ Dashboard 27 (พัสดุหลายชิ้น) ---
  Widget _buildMultiPackageView(BuildContext context) {
    // นี่คือ Layout เดิมที่แสดงรายการพัสดุ
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Delivery Details Title ---
        const Text(
          'Delivery Details (MAY23230024)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // --- Pick up location ---
        _buildInfoRow(
          Icons.gps_fixed,
          'Pick up location',
          const Color(0xFF4A25E1),
        ),
        const SizedBox(height: 16),

        // --- รายการพัสดุ ---
        Column(
          children: _packages.map((package) {
            int index = _packages.indexOf(package);
            return _buildPackageCard(
              imageUrl: _simulatedPackageImageUrl, // ใช้รูปจำลองขนาดเล็ก
              title: 'Package ${index + 1}',
              subtitle: package['destination']!,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // --- Add Another Package ---
        // ซ่อนปุ่มเมื่อมี 5 รายการแล้ว
        if (_packages.length < 5)
          _buildAddPackageRow(context)
        else
          const SizedBox(height: 24), // ใส่ Sizedbox เปล่าๆ เพื่อรักษา layout
      ],
    );
  }

  // --- Widget ส่วนล่างสุดของจอ (ใช้ร่วมกัน) ---
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      color: Colors.grey[50],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // (ลบ Text อธิบาย "add up to 5" ออก)
          const SizedBox(height: 20),
          // 17. ⭐️ ปุ่ม "Confirm Order"
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                ) // ⬅️ แสดง Loading
              : ElevatedButton(
                  onPressed: _confirmOrderOnServer, // ⬅️ เรียกฟังก์ชันยิง API
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A25E1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // --- Helper Widgets (ใช้ร่วมกัน) ---

  // Helper Widget สำหรับหัวข้อ (Sender/Receiver)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper Widget สำหรับสร้างการ์ดพัสดุแต่ละอัน (Dashboard 27)
  Widget _buildPackageCard({
    required String imageUrl,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // รูปภาพ
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // ข้อความ
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget สำหรับแถวข้อมูล (ไอคอน + ข้อความ)
  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    // (แก้ไขเล็กน้อยให้รองรับข้อความยาว)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ เพิ่ม
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  // Helper Widget สำหรับปุ่ม "Add Another Package"
  Widget _buildAddPackageRow(BuildContext context) {
    return InkWell(
      onTap: _addPackage, // เรียกฟังก์ชัน _addPackage เมื่อกด
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: const [
            Icon(Icons.add_circle_outline, color: Color(0xFF4A25E1), size: 24),
            SizedBox(width: 16),
            Text(
              'Add Another Package',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A25E1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
