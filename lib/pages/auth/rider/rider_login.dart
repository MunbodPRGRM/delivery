import 'dart:convert';

import 'package:delivery_app/config/internal_config.dart';
import 'package:delivery_app/model/request/rider_login_post_req.dart';
import 'package:delivery_app/model/response/rider_login_post_res.dart';
import 'package:delivery_app/pages/home/rider_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RiderLogin extends StatefulWidget {
  const RiderLogin({super.key});

  @override
  State<RiderLogin> createState() => _RiderLoginState();
}

class _RiderLoginState extends State<RiderLogin> {
  bool _obscureText = true; // เริ่มต้นเป็นซ่อนรหัสผ่าน

  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3532D7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ชื่อแอป
              const Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 53),

              // ช่อง Phone
              Material(
                color: Colors.white,
                elevation: 4,
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: const TextStyle(color: Color(0xFF98A1B3)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF98A1B3),
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

              const SizedBox(height: 32),

              // ช่อง Password
              Material(
                color: Colors.white,
                elevation: 4,
                child: TextField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFF98A1B3)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF98A1B3),
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
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF98A1B3),
                      ),
                      onPressed: ToggelPassword,
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFF98A1B3)),
                  cursorColor: Color(0xFF98A1B3),
                ),
              ),

              const SizedBox(height: 56),

              // ปุ่ม Log In
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: LoginButton,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3532D7),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Log In'),
                ),
              ),

              const SizedBox(height: 19),

              // ปุ่ม Back
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: BackButton,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3532D7),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void ToggelPassword() {
    setState(() {
      _obscureText = !_obscureText; // toggle ซ่อน/แสดง
    });
  }

  Future<void> LoginButton() async {
    final loginReq = RiderLoginPostRequest(
      phone: phoneController.text,
      password: passwordController.text,
    );

    final url = Uri.parse("$API_ENDPOINT/riders/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(loginReq.toJson()),
    );

    if (response.statusCode == 200) {
      final res = RiderLoginPostResponse.fromJson(jsonDecode(response.body));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RiderHome(rider: res.rider)),
      );
    } else {
      final error = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("เข้าสู่ระบบล้มเหลว"),
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
  }

  void BackButton() {
    Navigator.pop(context);
  }
}
