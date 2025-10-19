import 'dart:convert';
import 'dart:io';

import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/response/rider_register_post_res.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RiderRegister extends StatefulWidget {
  const RiderRegister({super.key});

  @override
  State<RiderRegister> createState() => _RiderRegisterState();
}

class _RiderRegisterState extends State<RiderRegister> {
  bool _obscureText = true;
  bool _obscureTextConfirm = true;

  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController numberPlateController = TextEditingController();

  final _picker = ImagePicker();
  File? _imageFile;
  File? _vehicleFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVehicle(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _vehicleFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context); // ปิด dialog
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context); // ปิด dialog
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVehicleSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context); // ปิด dialog
                  _pickVehicle(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context); // ปิด dialog
                  _pickVehicle(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void Popup() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แถวด้านบน (ปุ่มกลับและเวลา)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ปุ่ม Back
                    Container(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        onPressed: Popup,
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF414141),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ช่องอัพโหลดรูปภาพ (วงกลม)
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD0D0D0).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Color(0xFFD0D0D0),
                              width: 2,
                            ),
                          ),
                          child: _imageFile == null
                              ? Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFFD0D0D0),
                                  size: 40,
                                )
                              : ClipOval(
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ช่อง User Name
                const Text(
                  'User Name',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  elevation: 4,
                  child: TextField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      labelText: 'User Name',
                      labelStyle: const TextStyle(color: Color(0xFF98A1B3)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFF98A1B3),
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFF98A1B3)),
                    cursorColor: Color(0xFF98A1B3),
                  ),
                ),

                const SizedBox(height: 20),

                // ช่อง Phone
                const Text(
                  'Phone',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  elevation: 4,
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: const TextStyle(color: Color(0xFF98A1B3)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Color(0xFF98A1B3),
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFF98A1B3)),
                    cursorColor: Color(0xFF98A1B3),
                  ),
                ),

                const SizedBox(height: 20),

                // ช่อง Password
                const Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  elevation: 4,
                  child: TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFF98A1B3)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF98A1B3),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF98A1B3),
                        ),
                        onPressed: ToggelPassword,
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFF98A1B3)),
                    cursorColor: Color(0xFF98A1B3),
                  ),
                ),

                const SizedBox(height: 20),

                // ช่อง Confirm Password
                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  elevation: 4,
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureTextConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: const TextStyle(color: Color(0xFF98A1B3)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF98A1B3),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureTextConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF98A1B3),
                        ),
                        onPressed: ToggelConfirmPassword,
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFF98A1B3)),
                    cursorColor: Color(0xFF98A1B3),
                  ),
                ),

                const SizedBox(height: 28),

                // ช่องอัพโหลดรูปภาพ
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showVehicleSourceDialog,
                        child: Container(
                          width: 300,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD0D0D0).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: Color(0xFFD0D0D0),
                              width: 2,
                            ),
                          ),
                          child: _vehicleFile == null
                              ? Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFFD0D0D0),
                                  size: 40,
                                )
                              : Container(
                                  width: 300,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD0D0D0,
                                    ).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(0),
                                    border: Border.all(
                                      color: Color(0xFFD0D0D0),
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.file(
                                    _vehicleFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Number Plate',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  elevation: 4,
                  child: TextField(
                    controller: numberPlateController,
                    decoration: InputDecoration(
                      labelText: 'Number Plate',
                      labelStyle: const TextStyle(color: Color(0xFF98A1B3)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E7EE),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      prefixIcon: const Icon(
                        Icons.motorcycle,
                        color: Color(0xFF98A1B3),
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFF98A1B3)),
                    cursorColor: Color(0xFF98A1B3),
                  ),
                ),

                const SizedBox(height: 40),

                // ปุ่ม Submit
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: Submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3532D7),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> Submit() async {
    final url = Uri.parse("$API_ENDPOINT/riders/register");

    try {
      var request = http.MultipartRequest("POST", url);

      // fields
      request.fields["phone"] = phoneController.text;
      request.fields["password"] = passwordController.text;
      request.fields["name"] = userNameController.text;
      request.fields["plate_number"] = numberPlateController.text;

      // profile picture
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("profile_pic", _imageFile!.path),
        );
      }

      // vehicle picture (optional)
      if (_vehicleFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("vehicle_pic", _vehicleFile!.path),
        );
      }

      // ส่ง request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = RiderRegisterPostResponse.fromJson(
          jsonDecode(responseBody),
        );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("สมัครสำเร็จ"),
            content: Text("Rider: ${res.rider.name}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        final error = jsonDecode(responseBody);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("สมัครล้มเหลว"),
            content: Text(error["error"] ?? "เกิดข้อผิดพลาด"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("สมัครล้มเหลว"),
          content: Text("เกิดข้อผิดพลาด: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void ToggelConfirmPassword() {
    setState(() {
      _obscureTextConfirm = !_obscureTextConfirm; // toggle ซ่อน/แสดง
    });
  }

  void ToggelPassword() {
    setState(() {
      _obscureText = !_obscureText; // toggle ซ่อน/แสดง
    });
  }
}
