import 'dart:convert';
import 'dart:io';

import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/customer_address_get_res.dart';
import 'package:delivery_app/model/response/customer_login_post_res.dart';
import 'package:delivery_app/pages/customer/confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// หน้าจอหลัก (Dashboard 23)
class DeliveryFormScreen extends StatefulWidget {
  final User user;
  final XFile imageFile;
  const DeliveryFormScreen({
    super.key,
    required this.user,
    required this.imageFile,
  });

  @override
  State<DeliveryFormScreen> createState() => _DeliveryFormScreenState();
}

class _DeliveryFormScreenState extends State<DeliveryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State สำหรับ "ที่อยู่ผู้ส่ง" (From)
  List<Address> _senderAddresses = [];
  Address? _selectedSenderAddress;
  bool _isLoadingSenderAddresses = true;

  // State สำหรับ "ผู้รับ" (Receiver)
  bool _isSearchingReceiver = false;
  User? _foundReceiver;
  List<Address> _receiverAddresses = [];
  Address? _selectedReceiverAddress;

  @override
  void initState() {
    super.initState();
    // 2. เมื่อหน้าจอเริ่มทำงาน, ให้ดึง "ที่อยู่ของผู้ส่ง" (ตัวเราเอง) มาเตรียมไว้
    _fetchSenderAddresses();
  }

  Future<void> _fetchSenderAddresses() async {
    setState(() {
      _isLoadingSenderAddresses = true;
    });
    try {
      final String userId = widget.user.id.toString();
      final String apiUrl = "$API_ENDPOINT/users/address?userId=$userId";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _senderAddresses = jsonList
              .map((json) => Address.fromJson(json))
              .toList();
          _isLoadingSenderAddresses = false;
        });
      } else {
        // ... (จัดการ Error)
      }
    } catch (e) {
      // ... (จัดการ Error)
    }
  }

  Future<void> _searchReceiver() async {
    if (_receiverPhoneController.text.isEmpty) return;

    setState(() {
      _isSearchingReceiver = true;
      _foundReceiver = null;
      _receiverAddresses = [];
      _selectedReceiverAddress = null;
    });

    try {
      final String phone = _receiverPhoneController.text;
      final String apiUrl = "$API_ENDPOINT/users/find-by-phone?phone=$phone";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['user'];
        final addressesJson = data['addresses'] as List;

        setState(() {
          // (สำคัญ!) เราต้องมี User.fromJson ใน Model ของเรา
          _foundReceiver = User.fromJson(userJson);
          _receiverAddresses = addressesJson
              .map((json) => Address.fromJson(json))
              .toList();
          _isSearchingReceiver = false;
        });
      } else {
        final error = jsonDecode(response.body)['error'];
        setState(() {
          _isSearchingReceiver = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      setState(() {
        _isSearchingReceiver = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('การเชื่อมต่อล้มเหลว: $e')));
    }
  }

  void _submitDelivery() {
    // 1. ตรวจสอบ Form ก่อน (ใช้ ! ได้ แต่ควรเช็ค null ก่อน)
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      // ถ้า form ไม่ผ่าน validation ก็ไม่ต้องทำอะไร
      print('DEBUG: ติดที่ Form Validate (ช่องรายละเอียดว่าง)');
      return;
    }

    // 2. ตรวจสอบที่อยู่ต้นทาง
    if (_selectedSenderAddress == null) {
      print('DEBUG: ติดที่ยังไม่เลือกที่อยู่ผู้ส่ง (From)');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกที่อยู่ต้นทาง')));
      return;
    }

    // 3. ตรวจสอบที่อยู่ปลายทาง
    if (_selectedReceiverAddress == null) {
      print('DEBUG: ติดที่ยังไม่เลือกที่อยู่ผู้รับ (To)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาค้นหาและเลือกที่อยู่ปลายทาง')),
      );
      return;
    }

    // 4. ❗️❗️ เพิ่มการตรวจสอบนี้ ❗️❗️
    //   (นี่คือจุดที่แก้บั๊ก Null check operator)
    if (_foundReceiver == null) {
      print('DEBUG: ติดที่ _foundReceiver เป็น null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาด: ไม่พบข้อมูลผู้รับ กรุณาลองค้นหาใหม่'),
        ),
      );
      return;
    }

    // รวบรวมข้อมูลทั้งหมด
    User senderUser = widget.user;
    Address senderAddress = _selectedSenderAddress!;
    User receiverUser = _foundReceiver!;
    Address receiverAddress = _selectedReceiverAddress!;
    String description = _descriptionController.text;
    XFile image = widget.imageFile;

    // ส่งข้อมูลทั้งหมดไปหน้า ConfirmationScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          senderUser: senderUser,
          senderAddress: senderAddress,
          receiverUser: receiverUser,
          receiverAddress: receiverAddress,
          itemDescription: description,
          imageFile: image,
        ),
      ),
    );
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
            // ย้อนกลับ
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Delivery',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- รูปพัสดุที่ส่งมา ---
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imageFile.path),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Section: Location (แก้ไข) ---
                _buildSectionTitle('Location'),
                const SizedBox(height: 16),

                // 7. เปลี่ยน "From" เป็น Dropdown ที่อยู่ผู้ส่ง
                _buildDropdownAddresses(
                  label: 'From (ที่อยู่ผู้ส่ง)',
                  hint: _isLoadingSenderAddresses
                      ? 'กำลังโหลดที่อยู่...'
                      : 'เลือกที่อยู่ของคุณ',
                  items: _senderAddresses,
                  selectedValue: _selectedSenderAddress,
                  onChanged: (address) {
                    setState(() {
                      _selectedSenderAddress = address;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // --- Section: Receiver (แก้ไข) ---
                _buildSectionTitle('Receiver'),
                const SizedBox(height: 16),

                // 8. ช่องค้นหาเบอร์โทรผู้รับ
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _receiverPhoneController,
                        label: 'Receiver\'s Phone Number',
                        hint: 'ค้นหาเบอร์ผู้รับ',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isSearchingReceiver
                        ? const CircularProgressIndicator()
                        : IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Color(0xFF4A25E1),
                            ),
                            onPressed: _searchReceiver,
                          ),
                  ],
                ),
                const SizedBox(height: 16),

                // 9. แสดงผลลัพธ์การค้นหา (ชื่อ และ ที่อยู่ปลายทาง)
                if (_foundReceiver != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ชื่อผู้รับ: ${_foundReceiver!.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownAddresses(
                        label: 'To (ที่อยู่ผู้รับ)',
                        hint: _receiverAddresses.isEmpty
                            ? 'ผู้รับยังไม่มีที่อยู่บันทึกไว้'
                            : 'เลือกที่อยู่ปลายทาง',
                        items: _receiverAddresses,
                        selectedValue: _selectedReceiverAddress,
                        onChanged: (address) {
                          setState(() {
                            _selectedReceiverAddress = address;
                          });
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // 10. (เพิ่ม) Section: รายละเอียดพัสดุ
                _buildSectionTitle('Package Details'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Item Description',
                  hint: 'เช่น เอกสาร, เสื้อผ้า, ฯลฯ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุรายละเอียดพัสดุ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // --- ปุ่ม "ต่อไป" ---
                const SizedBox(height: 32), // เพิ่มระยะห่าง
                // ทำให้ปุ่มเต็มความกว้าง
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A25E1), // ใช้สีม่วงหลัก
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ต่อไป', // 'Next' in Thai
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget สำหรับสร้างหัวข้อ Section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Helper Widget สำหรับสร้าง Text Field ทั่วไป
  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // ⬇️⬇️⬇️ แก้จาก TextField เป็น TextFormField ⬇️⬇️⬇️
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          // ⭐️ และส่ง validator เข้าไป
          validator: validator,
        ),
        // ⬆️⬆️⬆️ แก้ไขตรงนี้ ⬆️⬆️⬆️
      ],
    );
  }

  Widget _buildDropdownAddresses({
    required String label,
    required String hint,
    required List<Address> items,
    required Address? selectedValue,
    required void Function(Address?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Address>(
          value: selectedValue,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          items: items.map((Address address) {
            // ใช้วิธีแสดงชื่อสถานที่ (บรรทัดแรก)
            String title = address.address.split(',')[0];
            return DropdownMenuItem<Address>(
              value: address,
              child: Tooltip(
                // เพิ่ม Tooltip เพื่อให้เห็นที่อยู่เต็ม
                message: address.address,
                child: Text(title, overflow: TextOverflow.ellipsis),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'กรุณาเลือกที่อยู่' : null,
        ),
      ],
    );
  }
}
