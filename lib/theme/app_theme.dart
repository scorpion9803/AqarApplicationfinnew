import 'package:flutter/material.dart';

class AppTheme {
  // 1. تثبيت الألوان الملكية الفخمة كـ constants للاستخدام في أي مكان بالتطبيق
  static const Color primaryDark = Color(0xFF0F172A);   // كحلي داكن جداً
  static const Color secondaryDark = Color(0xFF020617); // أسود فحمي للخلفيات العميقة
  static const Color goldAccent = Color(0xFFD4AF37);    // ذهبي ملكي مطفي
  static const Color textLight = Color(0xFFF8FAFC);     // أبيض ناصع
  static const Color fieldBg = Color(0xFF1E293B);        // خلفية الحقول والكروت

  // 2. بناء كائن الـ ThemeData الموحد
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: secondaryDark,
      primaryColor: goldAccent,
      
      // إعداد الخط الافتراضي (Cairo) للتطبيق بالكامل
      fontFamily: 'Cairo', 

      // تخصيص ثيم الـ AppBar ليكون متناسقاً في كل الشاشات
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: goldAccent),
        titleTextStyle: TextStyle(
          color: goldAccent,
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // تخصيص ثيم حقول الإدخال (TextField / TextFormField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldBg,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldAccent, width: 1),
        ),
      ),

      // تخصيص ثيم أزرار الـ ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: secondaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
      ),

      // تخصيص ثيم الـ BottomNavigationBar السفلي ليتوافق مع شاشة الـ Layout
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryDark,
        selectedItemColor: goldAccent,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
    );
  }
}