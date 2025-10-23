import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:delivery_app/model/response/customer_login_post_res.dart';
import 'package:delivery_app/pages/customer/delivery_form_screen.dart';
import 'package:flutter/material.dart';

// หน้าจอ Dashboard 21 (Upload Picture)
// เปลี่ยนเป็น StatefulWidget เพื่อจัดการสถานะการเลือกรูป
class UploadPackageScreen extends StatefulWidget {
  final User user;
  const UploadPackageScreen({super.key, required this.user});

  @override
  State<UploadPackageScreen> createState() => _UploadPackageScreenState();
}

class _UploadPackageScreenState extends State<UploadPackageScreen> {
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // ฟังก์ชันสำหรับปุ่ม
  void _handleButtonPress() {
    if (_pickedImage != null) {
      // ✅ ถ้ารูปถูกเลือกแล้ว (ปุ่มขึ้นว่า 'ต่อไป')
      // ให้ไปหน้า DeliveryFormScreen
      print('Going to next page with image: ${_pickedImage!.path}');

      Navigator.push(
        context,
        MaterialPageRoute(
          // 3. ส่งไฟล์รูป (XFile) ไปยังหน้าถัดไป
          builder: (context) =>
              DeliveryFormScreen(user: widget.user, imageFile: _pickedImage!),
        ),
      );
    } else {
      // ❌ ถ้ารูปยังไม่ถูกเลือก (ปุ่มขึ้นว่า 'กล้อง')
      // ให้เปิดกล้อง
      _pickImage();
    }
  }

  Future<void> _pickImage() async {
    try {
      // เปิดกล้อง
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // ลดคุณภาพรูปเล็กน้อย (0-100)
      );

      if (image != null) {
        setState(() {
          _pickedImage = image; // เก็บไฟล์ที่เลือก
        });
        print('Image picked! Path: ${image.path}');
      } else {
        print('User cancelled image pick.');
      }
    } catch (e) {
      print('Failed to pick image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่สามารถเปิดกล้องได้: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Delivery',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          // จัดให้อยู่กลางๆ แต่ไม่จำเป็นต้อง center เป๊ะๆ
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 64), // ดันลงมาจาก AppBar
            // --- ส่วนแสดงผล (เปลี่ยนตามสถานะ) ---
            if (_pickedImage != null)
              _buildImagePlaceholder() // แสดงรูปที่ "เลือกแล้ว"
            else
              _buildUploadPrompt(), // แสดง UI เริ่มต้น

            const Spacer(), // ดันปุ่มไปด้านล่าง
            // --- ปุ่ม (เปลี่ยนตามสถานะ) ---
            ElevatedButton(
              onPressed: _handleButtonPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A25E1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _pickedImage != null
                    ? 'ต่อไป'
                    : 'กล้อง', // 7. แก้ไขเงื่อนไขข้อความ
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40), // เพิ่มช่องว่างด้านล่างปุ่ม
          ],
        ),
      ),
    );
  }

  // Widget สำหรับแสดง UI เริ่มต้น (ไอคอน + ข้อความ)
  Widget _buildUploadPrompt() {
    return Column(
      children: [
        // 1. ไอคอนกล่องพัสดุ
        Icon(
          Icons.inventory_2_outlined, // ไอคอนกล่อง
          size: 150,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 32),

        // 2. ข้อความ Title
        const Text(
          'A picture of the package',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // 3. ข้อความอธิบาย
        Text(
          'Please upload a picture of your package. Ensure you capture all the sides of the package.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
        ),
      ],
    );
  }

  // Widget สำหรับแสดงรูปที่ "เลือกแล้ว" (จำลอง)
  Widget _buildImagePlaceholder() {
    // อ้างอิงดีไซน์จาก Dashboard 22
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF4A25E1), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            // ❗️เปลี่ยนจาก Image.network เป็น Image.file
            child: Image.file(
              File(_pickedImage!.path), // ❗️ใช้ File() จาก dart:io
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Package Image Ready',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Press "Next" to continue.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
        ),
      ],
    );
  }
}
