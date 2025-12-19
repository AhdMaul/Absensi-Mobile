import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/app_colors.dart';

class DateRangeField extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final VoidCallback onPickDateRange;

  const DateRangeField({super.key, required this.selectedDateRange, required this.onPickDateRange});

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDateRange != null;

    String dateText = "Pilih Rentang Tanggal";
    String durationText = "";
    if (hasDate) {
      final start = DateFormat('dd MMM', 'id_ID').format(selectedDateRange!.start);
      final end = DateFormat('dd MMM yyyy', 'id_ID').format(selectedDateRange!.end);
      dateText = "$start - $end";
      final days = selectedDateRange!.end.difference(selectedDateRange!.start).inDays + 1;
      durationText = "$days Hari";
    }

    return InkWell(
      onTap: onPickDateRange,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDate ? AppColors.neonCyan : Colors.grey.shade300,
            width: hasDate ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: hasDate ? AppColors.neonCyan.withOpacity(0.1) : Colors.transparent,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasDate ? AppColors.neonCyan.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: hasDate ? AppColors.neonCyan : Colors.grey.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: hasDate ? AppColors.textPrimary : Colors.grey.shade400,
                    ),
                  ),
                  if (hasDate)
                    Text(
                      "Durasi izin: $durationText",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neonCyan,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
