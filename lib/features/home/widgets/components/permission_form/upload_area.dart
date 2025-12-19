import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';

class UploadArea extends StatelessWidget {
  final String? fileName;
  final bool isSick;
  final VoidCallback onPickFile;
  final VoidCallback onClearFile;

  const UploadArea({
    super.key,
    required this.fileName,
    required this.isSick,
    required this.onPickFile,
    required this.onClearFile,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    final accent = AppColors.error;

    return InkWell(
      onTap: hasFile ? null : onPickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: hasFile ? accent.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: hasFile
              ? Border.all(color: accent, width: 1.5)
              : Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.none,
                ),
        ),
        child: Center(
          child: hasFile
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: Icon(Icons.file_present_rounded, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hankenGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Tap silang untuk hapus",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.grey),
                      onPressed: onClearFile,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap untuk upload surat dokter",
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "(Format: JPG, PNG, PDF)",
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
