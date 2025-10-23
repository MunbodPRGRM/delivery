import 'dart:convert';

import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/delivery_job_get_res.dart';
import 'package:delivery_app/model/response/rider_login_post_res.dart';
import 'package:delivery_app/pages/home/rider_home.dart';
import 'package:delivery_app/pages/profile/rider_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JobPage extends StatefulWidget {
  final Rider rider;
  const JobPage({super.key, required this.rider});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  bool _isLoading = true;
  List<DeliveryJob> _jobs = [];
  final String _baseUrl = "$API_ENDPOINT/uploads/";

  @override
  void initState() {
    super.initState();
    // 3. ⭐️ (เพิ่ม) เรียก API เมื่อหน้าจอเริ่ม
    _fetchAvailableJobs();
  }

  Future<void> _fetchAvailableJobs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final String apiUrl = "$API_ENDPOINT/deliveries/available";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _jobs = jsonList.map((json) => DeliveryJob.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // (จัดการ Error)
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // (จัดการ Error)
    }
  }

  Future<void> _acceptJob(int jobId) async {
    // (แสดง Loading เฉพาะจุด หรือ โหลดทั้งหน้า)
    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl = "$API_ENDPOINT/deliveries/$jobId/accept";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'riderId': widget.rider.id.toString(), // ⬅️ ส่ง ID ของไรเดอร์
        }),
      );

      if (response.statusCode == 200) {
        // ถ้ารับงานสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รับงานสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        // TODO: อาจจะนำทางไปหน้า "งานของฉัน" หรือ "แผนที่"
        // หรืออย่างน้อยก็โหลดรายการใหม่
        _fetchAvailableJobs();
      } else {
        // ถ้ารับไม่สำเร็จ (เช่น งานโดนตัดหน้า)
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('การเชื่อมต่อล้มเหลว: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RiderHome(rider: widget.rider)),
      );
    } else if (index == 1) {
      // อยู่หน้า JobPage เอง ไม่ต้องทำอะไร
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RiderProfile(rider: widget.rider),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobs
                .isEmpty // ⬅️ ใช้ _jobs.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _jobs.length, // ⬅️ ใช้ _jobs.length
              itemBuilder: (context, index) {
                final DeliveryJob job = _jobs[index];
                return _buildJobCard(context, job);
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // ✅ ให้แสดง label ทุกอัน
        currentIndex: 1, // อยู่หน้าแรก
        selectedItemColor: const Color(0xFF4A25E1), // สีม่วงเข้ม
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'รับงาน'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, DeliveryJob job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // 8. ⭐️ (แก้ไข) แสดงรูปจริง
              child: Image.network(
                job.photoStatus1 != null
                    ? "$_baseUrl${job.photoStatus1}"
                    : 'https://placehold.co/60x60/e8e0ff/4A25E1?text=Package',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job ID: ${job.id}', // ⬅️ แสดง ID
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ส่งไปที่: ${job.destinationAddress}', // ⬅️ แสดงที่อยู่
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 9. ⭐️ (แก้ไข) ทำให้ปุ่ม "รับงาน" กดได้
            InkWell(
              onTap: () => _acceptJob(job.id), // ⬅️ เรียกฟังก์ชันรับงาน
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'รับงาน',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีงานในขณะนี้',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
