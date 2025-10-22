import 'dart:convert';
import 'dart:developer';

import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/customer_login_post_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class AddAddressMapPage extends StatefulWidget {
  final User user;
  const AddAddressMapPage({super.key, required this.user});

  @override
  State<AddAddressMapPage> createState() => _AddAddressMapPageState();
}

class _AddAddressMapPageState extends State<AddAddressMapPage> {
  final MapController _mapController = MapController();
  // final TextEditingController _locationNameController = TextEditingController(); // 📍 แก้ไข: เอาออก
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _coordinatesController =
      TextEditingController(); // 📍 แก้ไข: เพิ่มตัวนี้

  LatLng? _currentPosition;
  LatLng? _selectedPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. ตรวจสอบว่าเปิด Service GPS หรือยัง
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเปิด GPS')));
      return;
    }

    // 2. ขอ Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถขออนุญาตเข้าถึงตำแหน่งได้')),
      );
      return;
    }

    // 3. ดึงตำแหน่งปัจจุบัน
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _selectedPosition = _currentPosition;
        _isLoading = false;
        _mapController.move(_currentPosition!, 15.0);
        _reverseGeocode(_currentPosition!); // แปลงพิกัดเป็นที่อยู่
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // 4. แปลงพิกัด (LatLng) เป็นชื่อที่อยู่ (String)
  Future<void> _reverseGeocode(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.name ?? ''}, ${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}';
        _addressController.text = address;
      }

      // 📍 แก้ไข: อัปเดตค่าพิกัดใน Controller
      _coordinatesController.text =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      _addressController.text = 'ไม่สามารถค้นหาที่อยู่ได้';
      _coordinatesController.text = 'N/A'; // 📍 แก้ไข
    }
  }

  // 5. เมื่อผู้ใช้แตะบนแผนที่
  void _handleTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _reverseGeocode(
      position,
    ); // 📍 แก้ไข: คำสั่งนี้จะอัปเดตทั้งที่อยู่และพิกัดให้เอง
  }

  // 6. ฟังก์ชันยืนยันเพื่อบันทึกที่อยู่
  void _confirmAddress() async {
    // 2. เติม async
    if (_addressController.text.isEmpty ||
        _addressController.text == 'ไม่สามารถค้นหาที่อยู่ได้' ||
        _selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณารอ... กำลังค้นหาพิกัด')),
      );
      return;
    }

    // 3. ⭐️⭐️⭐️ ใส่ IP ของ Node.js Server ⭐️⭐️⭐️
    final String apiUrl = "$API_ENDPOINT/users/address";

    // 4. เตรียมข้อมูลที่จะส่งไป
    final String locationName = _addressController.text;
    final String gpsCoordinates =
        '${_selectedPosition!.latitude},${_selectedPosition!.longitude}';
    final String userId = widget.user.id.toString();

    // 5. แสดง Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 6. ยิง API แบบ POST
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'userId': userId,
          'locationName': locationName, // 📍 แก้ไข: ส่งที่อยู่ที่แปลงแล้วไปแทน
          'gpsCoordinates': gpsCoordinates,
        }),
      );

      // 7. ซ่อน Loading
      Navigator.of(context).pop();

      if (response.statusCode == 201) {
        // 8. ถ้าบันทึกสำเร็จ (201 Created)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('บันทึกที่อยู่สำเร็จ!')));
        Navigator.pop(context); // ย้อนกลับไปหน้า Profile
      } else {
        // 9. ถ้า Backend ส่ง Error กลับมา
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${errorData['error']}')),
        );
        log('เกิดข้อผิดพลาด: ${errorData['error']}');
      }
    } catch (e) {
      // 10. ถ้ามีปัญหาการเชื่อมต่อ (เช่น ปิด server, ไม่มี wifi)
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('การเชื่อมต่อล้มเหลว: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกที่อยู่'),
        backgroundColor: const Color(0xFF3532D7),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 8. แสดงแผนที่
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentPosition ??
                        const LatLng(
                          13.7563,
                          100.5018,
                        ), // ถ้าไม่มี GPS ให้ไป กทม.
                    initialZoom: 15.0,
                    onTap: _handleTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key={apiKey}',
                      additionalOptions: {
                        'apiKey':
                            'hKjBu51NtvFgjybUWSEP', // ⬅️ วาง Key ของคุณตรงนี้
                      },
                      userAgentPackageName:
                          'com.mycompany.deliveryapp', // ใส่ชื่อ package ของคุณ
                    ),

                    // 9. แสดงหมุดที่เลือก
                    if (_selectedPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _selectedPosition!,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40.0,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // 10. กล่องข้อมูลด้านล่าง
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Card(
                    margin: const EdgeInsets.all(0),
                    elevation: 10,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _addressController,
                            enabled: false,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'ที่อยู่ที่เลือก',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _coordinatesController,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'พิกัด (ละติจูด, ลองจิจูด)',
                              prefixIcon: Icon(Icons.map_outlined),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3532D7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _confirmAddress,
                            child: const Text(
                              'ยืนยันที่อยู่',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
