import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart'; // Import ActivityItem dari sini
import '../widgets/activity_tile.dart'; // Widget yang baru kita pisah

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Simulasi Data Banyak
  final List<ActivityItem> _allActivities = List.generate(10, (index) {
    return ActivityItem(
      date: "${index + 1} November 2025",
      status: index % 3 == 0 ? "Telat (08:10)" : "Tepat Waktu",
      checkIn: index % 3 == 0 ? "08:10" : "07:55",
      checkOut: "17:00",
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- BACKGROUND (Sama seperti Home/Profile) ---
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Stack(
                children: [
                  Positioned(
                    top: -50, right: -50,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100, left: -50,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonGreen.withOpacity(0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- CONTENT ---
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        ),
                      ),
                      Text(
                        'Riwayat Absensi',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Placeholder icon filter
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, size: 18),
                      ),
                    ],
                  ),
                ),

                // List Absensi
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _allActivities.length,
                    itemBuilder: (context, index) {
                      return ActivityTile(activity: _allActivities[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}