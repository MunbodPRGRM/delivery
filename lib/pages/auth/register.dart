import 'package:delivery_app/pages/auth/customer/customer_register.dart';
import 'package:delivery_app/pages/auth/login.dart';
import 'package:delivery_app/pages/auth/rider/rider_register.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              const Text(
                'Register',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 60),

              // ปุ่ม Rider
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: Rider,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3532D7),
                    foregroundColor: Colors.white,
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

              const SizedBox(height: 34),

              // ปุ่ม Customer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: Customer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3532D7),
                    foregroundColor: Colors.white,
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

              // ลิงก์ Log In
              TextButton(
                onPressed: LoginPage,
                child: const Text(
                  'Already have an account? Log In',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color.fromARGB(255, 0, 0, 0),
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

  void Rider() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RiderRegister()),
    );
  }

  void Customer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomerRegister()),
    );
  }

  void LoginPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }
}
