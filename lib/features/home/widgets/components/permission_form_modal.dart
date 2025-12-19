// lib/features/home/widgets/components/permission_form_modal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../services/permission_service.dart';

// Subcomponents (Pastikan path import ini sesuai dengan struktur folder kamu)
import 'permission_form/toggle.dart';
import 'permission_form/date_range_field.dart';
import 'permission_form/reason_input.dart';
import 'permission_form/upload_area.dart';
import 'permission_form/submit_button.dart';

class PermissionFormModal extends StatefulWidget {
  final bool initialIsSick;

  const PermissionFormModal({super.key, required this.initialIsSick});

  @override
  State<PermissionFormModal> createState() => _PermissionFormModalState();
}

class _PermissionFormModalState extends State<PermissionFormModal> {
  late bool isSick;

  // State untuk Data Form
  DateTimeRange? _selectedDateRange;
  PlatformFile? _selectedFile;
  String? _fileName;

  // Controller Text
  final TextEditingController _reasonController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  // Service & Loading State
  final PermissionService _permissionService = PermissionService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isSick = widget.initialIsSick;
  }

  @override
  void dispose() {
    _noteFocus.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // --- LOGIC: DATE PICKER ---
  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 90)),
      initialDateRange: _selectedDateRange,
      saveText: "PILIH",
      cancelText: "BATAL",
      helpText: "PILIH RENTANG TANGGAL",
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.neonCyan,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: AppColors.neonCyan,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
              secondary: Color(0xFFE0F2FE),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: GoogleFonts.hankenGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // --- LOGIC: FILE PICKER ---
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _fileName = result.files.first.name;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil file: $e");
      _showSnackbar("Gagal memilih file", isError: true);
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  // --- LOGIC: SUBMIT DATA ---
  Future<void> _submitData() async {
    // 1. Validasi Input
    if (_selectedDateRange == null) {
      _showSnackbar("Mohon pilih rentang tanggal.", isError: true);
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      _showSnackbar("Mohon isi keterangan/alasan.", isError: true);
      return;
    }

    // Validasi Wajib File jika Sakit
    if (isSick && _selectedFile == null) {
      _showSnackbar("Mohon upload bukti sakit (Surat Dokter).", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Persiapkan File
      File? fileToSend;
      if (_selectedFile != null && _selectedFile!.path != null) {
        fileToSend = File(_selectedFile!.path!);
      }

      // 3. Kirim ke Backend via Service
      // Pastikan PermissionService sudah diperbaiki logic key-nya (date vs start_date)
      await _permissionService.submitPermission(
        type: isSick ? 'sick' : 'permit',
        startDate: _selectedDateRange!.start,
        endDate: _selectedDateRange!.end,
        reason: _reasonController.text,
        attachment: fileToSend,
      );

      // 4. Sukses
      if (mounted) {
        Navigator.pop(context); // Tutup Modal
        Get.snackbar(
          "Berhasil",
          "Pengajuan izin berhasil dikirim.",
          backgroundColor: AppColors.neonGreen,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // 5. Error Handling
      if (mounted) {
        String errorMsg = e.toString();
        // Bersihkan pesan error jika terlalu teknis
        if (errorMsg.contains("Exception:")) {
          errorMsg = errorMsg.replaceAll("Exception:", "").trim();
        }
        _showSnackbar("Gagal: $errorMsg", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? "Gagal" : "Info",
      message,
      backgroundColor: isError ? AppColors.error : AppColors.neonGreen,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.info_outline,
        color: Colors.white,
      ),
    );
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    // Mengambil padding bottom keyboard agar form naik saat diketik
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Formulir Pengajuan",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Silakan lengkapi data di bawah ini",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Toggle Jenis Izin
                  PermissionToggle(
                    isSick: isSick,
                    onChanged: (v) {
                      setState(() {
                        isSick = v;
                        // Reset file jika pindah ke 'Izin' karena opsional
                        if (!isSick) _clearFile();
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // 2. Input Tanggal
                  _buildSectionLabel("Tanggal & Durasi"),
                  const SizedBox(height: 8),
                  DateRangeField(
                    selectedDateRange: _selectedDateRange,
                    onPickDateRange: _pickDateRange,
                  ),

                  const SizedBox(height: 20),

                  // 3. Input Alasan
                  _buildSectionLabel("Keterangan"),
                  const SizedBox(height: 8),
                  ReasonInput(
                    controller: _reasonController,
                    focusNode: _noteFocus,
                  ),

                  // 4. Upload File (Animasi muncul jika sakit)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: isSick
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel("Bukti / Surat Dokter"),
                                const SizedBox(height: 8),
                                UploadArea(
                                  fileName: _fileName,
                                  isSick: isSick,
                                  onPickFile: _pickFile,
                                  onClearFile: _clearFile,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 32),

                  // 5. Tombol Submit
                  SubmitButton(isLoading: _isLoading, onPressed: _submitData),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
