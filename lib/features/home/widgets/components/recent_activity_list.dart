import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/home_controller.dart'; // Import model ActivityItem
import '../activity_tile.dart';

class RecentActivityList extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (activities.isEmpty)
          const Center(child: Text("Belum ada aktivitas hari ini."))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return ActivityTile(activity: activities[index]);
            },
          ),
      ],
    );
  }
}