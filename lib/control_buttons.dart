import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final IconData icon;
  final String? text; // جعل النص اختياريًا
  final VoidCallback? onPressed; // تغيير النوع إلى VoidCallback
  final double width; // إضافة متغير العرض
  final double height; // إضافة متغير الارتفاع

  const ControlButtons({
    super.key,
    required this.icon,
    this.text, // النص الآن اختياري
    this.onPressed,
    this.width = 120, // قيمة افتراضية للعرض
    this.height = 40, // قيمة افتراضية للارتفاع
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed, // تمرير onPressed مباشرة
        child: Container(
          //margin: const EdgeInsets.only(top: 30, left: 9, right: 9),
          margin: const EdgeInsets.only(top: 4, bottom: 4, left: 12, right: 12),
          padding: const EdgeInsets.all(1),
          width: width, // استخدام العرض الممرر أو الافتراضي
          height: height, // استخدام الارتفاع الممرر أو الافتراضي
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C00),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFFFFF).withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //const SizedBox(width: 12),
                Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
                //const SizedBox(width: 12),
                if (text != null) // شرط لإظهار النص إذا كان موجودًا
                  Text(
                    text!,
                    style: const TextStyle(
                      color: Colors.white, // تعيين اللون الأبيض للنص
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                //const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
