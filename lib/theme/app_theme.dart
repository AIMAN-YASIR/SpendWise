// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:get_storage/get_storage.dart';
//
// import 'screens/splash_screen.dart';
// import 'providers/transaction_provider.dart';
//
// // ── COLOR TOKENS ──────────────────────────────
// class AppColors {
//   static const kPrimary      = Color(0xFF534AB7);
//   static const kPrimaryLight = Color(0xFFEEEDFE);
//   static const kBg           = Color(0xFFF8F7FF);
//   static const kIncome       = Color(0xFF3B6D11);
//   static const kIncomeLight  = Color(0xFFEAF3DE);
//   static const kExpense      = Color(0xFFA32D2D);
//   static const kExpenseLight = Color(0xFFFCEBEB);
//   static const kAmber        = Color(0xFFBA7517);
//   static const kTeal         = Color(0xFF1D9E75);
//   static const kMuted        = Color(0xFF888780);
//   static const kBorder       = Color(0xFFD3D1C7);
//   static const kCard         = Color(0xFFFFFFFF);
// }
//
// // ── TEXT STYLES ───────────────────────────────
// class AppText {
//   static const titleLarge  = TextStyle(fontFamily: 'Helvetica', fontSize: 18, fontWeight: FontWeight.bold);
//   static const titleMedium = TextStyle(fontFamily: 'Helvetica', fontSize: 15, fontWeight: FontWeight.bold);
//   static const bodyMedium  = TextStyle(fontFamily: 'Helvetica', fontSize: 13);
//   static const bodySmall   = TextStyle(fontFamily: 'Helvetica', fontSize: 11);
//   static const labelSmall  = TextStyle(fontFamily: 'Helvetica', fontSize: 10, fontWeight: FontWeight.bold);
//   static const caption     = TextStyle(fontFamily: 'Helvetica', fontSize: 9, color: AppColors.kMuted);
// }
//
// // ── THEME ─────────────────────────────────────
// ThemeData buildAppTheme() {
//   return ThemeData(
//     scaffoldBackgroundColor: AppColors.kBg,
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: AppColors.kPrimary,
//       background: AppColors.kBg,
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: AppColors.kPrimary,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         fontFamily: 'Helvetica',
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//     ),
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       backgroundColor: AppColors.kPrimary,
//       foregroundColor: Colors.white,
//       elevation: 4,
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.kPrimary,
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         textStyle: AppText.titleMedium,
//         elevation: 0,
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.white,
//       labelStyle: AppText.bodyMedium.copyWith(color: AppColors.kMuted),
//       hintStyle: AppText.bodyMedium.copyWith(color: AppColors.kMuted),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.kBorder, width: 0.5),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.kBorder, width: 0.5),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.kPrimary, width: 1.5),
//       ),
//     ),
//     cardTheme: CardThemeData(
//       color: AppColors.kCard,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: const BorderSide(color: AppColors.kBorder, width: 0.5),
//       ),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Colors.white,
//       selectedItemColor: AppColors.kPrimary,
//       unselectedItemColor: AppColors.kMuted,
//       showUnselectedLabels: true,
//       type: BottomNavigationBarType.fixed,
//       elevation: 8,
//       selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//       unselectedLabelStyle: TextStyle(fontSize: 10),
//     ),
//     useMaterial3: false,
//   );
// }