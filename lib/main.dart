import 'package:cement_robot_v1_4/remote_control.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء شريط الـ Debug
      home: SafeArea(
          child: Expanded(
              child: SplashScreen())), // تعيين شاشة الترحيب كواجهة رئيسية
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // التأخير لمدة 3 ثواني قبل الانتقال للشاشة التالية
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const Expanded(
                child: RemoteControl())), // الانتقال إلى الشاشة الثانية
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // طريقة البناء لعرض صورة شاشة الترحيب
    return Scaffold(
      body: SizedBox(
        width: double.infinity, // جعل العرض يتناسب مع عرض الشاشة
        height: double.infinity, // جعل الارتفاع يتناسب مع ارتفاع الشاشة
        child: Image.asset(
          "images/welcome_page.png",
          fit: BoxFit.cover, // ملاءمة الصورة لتغطية الشاشة بالكامل
        ),
      ),
    );
  }
}
