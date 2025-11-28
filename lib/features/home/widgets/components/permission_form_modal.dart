import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class PermissionFormModal extends StatefulWidget {
  final bool initialIsSick;

  const PermissionFormModal({super.key, required this.initialIsSick});

  @override
  State<PermissionFormModal> createState() => _PermissionFormModalState();
}

class _PermissionFormModalState extends State<PermissionFormModal> {
  late bool isSick;
  DateTime? selectedDate;
  
  @override
  void initState() {
    super.initState();
    isSick = widget.initialIsSick;
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil tinggi keyboard agar form naik saat mengetik
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drag Handle (Garis kecil di atas)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Header Title
          Text(
            "Ajukan Kehadiran",
            style: GoogleFonts.hankenGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // 3. Toggle Pilihan (Sakit / Izin)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildToggleItem("Izin / Cuti", !isSick, () => setState(() => isSick = false)),
                _buildToggleItem("Sakit", isSick, () => setState(() => isSick = true)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Input Tanggal
          Text("Tanggal", style: _labelStyle),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate == null 
                        ? "Pilih Tanggal Mulai" 
                        : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate!),
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedDate == null ? Colors.grey.shade400 : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 5. Input Alasan (TextArea)
          Text("Keterangan", style: _labelStyle),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: isSick ? "Keluhan sakit yang dirasakan..." : "Alasan mengajukan izin...",
              hintStyle: GoogleFonts.hankenGrotesk(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.neonCyan),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 6. Upload Bukti (Optional style)
          if (isSick) ...[
            Text("Surat Dokter (Opsional)", style: _labelStyle),
            const SizedBox(height: 8),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), // Bisa diganti DottedBorder
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload_rounded, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      "Tap untuk upload",
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // 7. Tombol Submit
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Handle Submit Logic Here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBlack,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Kirim Pengajuan",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Toggle Button
  Widget _buildToggleItem(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.textPrimary : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );
}