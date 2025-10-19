import 'package:delivery_app/pages/auth/customer/customer_login.dart';
import 'package:delivery_app/pages/auth/register.dart';
import 'package:delivery_app/pages/auth/rider/rider_login.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3532D7), // พื้นหลังสี #3532D7
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

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

              const SizedBox(height: 60),

              // ปุ่ม Get Started
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: Rider,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3532D7),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Rider'),
                ),
              ),

              const SizedBox(height: 36),

              // ปุ่ม Log In
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: Customer,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3532D7),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Customer'),
                ),
              ),

              const SizedBox(height: 27),

              // ลิงก์ Register
              TextButton(
                onPressed: RegisterPage,
                child: const Text(
                  'Not have any account? Register',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void RegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  void Rider() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RiderLogin()),
    );
  }

  void Customer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomerLogin()),
    );
  }
}
