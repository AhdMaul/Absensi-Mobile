import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart'; 
import '../../../../core/theme/app_colors.dart';
// Pastikan path ini sesuai dengan struktur project Anda
import '../../services/permission_service.dart'; 

class PermissionFormModal extends StatefulWidget {
  final bool initialIsSick;

  const PermissionFormModal({super.key, required this.initialIsSick});

  @override
  State<PermissionFormModal> createState() => _PermissionFormModalState();
}

class _PermissionFormModalState extends State<PermissionFormModal> {
  late bool isSick;
  DateTime? selectedDate;
  
  // State untuk File
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

  // --- FUNGSI PILIH FILE ---
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
    }
  }

  // --- FUNGSI HAPUS FILE ---
  void _clearFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  // --- FUNGSI KIRIM DATA KE BACKEND (BARU) ---
  Future<void> _submitData() async {
    // 1. Validasi Input
    if (selectedDate == null) {
      _showSnackbar("Mohon pilih tanggal mulai.", isError: true);
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      _showSnackbar("Mohon isi keterangan/alasan.", isError: true);
      return;
    }
    // Validasi Khusus Sakit: Wajib ada file (Opsional, bisa dihapus jika tidak wajib)
    if (isSick && _selectedFile == null) {
       _showSnackbar("Mohon upload bukti sakit (Surat Dokter).", isError: true);
       return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Siapkan File (Hanya jika Sakit)
      File? fileToSend;
      if (isSick && _selectedFile != null) {
        fileToSend = File(_selectedFile!.path!);
      }

      // 3. Panggil Service
      await _permissionService.submitPermission(
        type: isSick ? 'sick' : 'permit', // 'permit' untuk izin/cuti
        date: selectedDate!,
        reason: _reasonController.text,
        attachment: fileToSend, // Akan null jika Izin, ini sudah benar
      );

      // 4. Sukses
      if (mounted) {
        Navigator.pop(context); // Tutup Modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengajuan berhasil dikirim!"),
            backgroundColor: AppColors.neonGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar("Gagal mengirim: ${e.toString()}", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message, 
          style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.neonGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          )
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90, 
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Text(
                "Ajukan Kehadiran",
                textAlign: TextAlign.center,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Toggle Izin/Sakit
              _buildSlidingToggle(),
              
              const SizedBox(height: 24),

              // Date Picker
              Text("Tanggal Mulai", style: _labelStyle),
              const SizedBox(height: 10),
              _buildDatePickerButton(context),

              const SizedBox(height: 20),

              // Input Keterangan
              Text("Keterangan", style: _labelStyle),
              const SizedBox(height: 10),
              _buildAnimatedNoteInput(),

              // Upload Area (Hanya muncul jika Sakit)
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
                          Text("Surat Dokter / Bukti", style: _labelStyle),
                          const SizedBox(height: 10),
                          _buildUploadArea(),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSlidingToggle() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            alignment: isSick ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildToggleLabel("Izin / Cuti", !isSick, () => setState(() => isSick = false)),
              _buildToggleLabel("Sakit", isSick, () => setState(() => isSick = true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleLabel(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 7)),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (picked != null) setState(() => selectedDate = picked);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: AppColors.neonCyan, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedDate == null ? "Pilih Tanggal" : DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate!),
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (selectedDate == null)
                       Text(
                        "Tap untuk membuka kalender",
                        style: GoogleFonts.hankenGrotesk(fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNoteInput() {
    return AnimatedBuilder(
      animation: _noteFocus,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _noteFocus.hasFocus ? Colors.white : AppColors.inputFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _noteFocus.hasFocus ? AppColors.neonCyan : AppColors.inputBorder,
              width: _noteFocus.hasFocus ? 1.5 : 1,
            ),
            boxShadow: _noteFocus.hasFocus
                ? [BoxShadow(color: AppColors.neonCyan.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: TextField(
            controller: _reasonController, // Jangan lupa controller!
            focusNode: _noteFocus,
            maxLines: 3,
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: isSick ? "Jelaskan keluhan sakit..." : "Alasan izin/cuti...",
              hintStyle: GoogleFonts.hankenGrotesk(color: Colors.grey.shade400),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadArea() {
    bool hasFile = _fileName != null;

    return GestureDetector(
      onTap: hasFile ? null : _pickFile, 
      child: Container(
        height: 90,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hasFile ? AppColors.neonCyan.withOpacity(0.05) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? AppColors.neonCyan : AppColors.inputBorder,
            width: hasFile ? 1.5 : 1,
            style: hasFile ? BorderStyle.solid : BorderStyle.solid, 
          ),
        ),
        child: hasFile 
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                    ]
                  ),
                  child: const Icon(Icons.description_rounded, color: AppColors.neonCyan, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fileName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.hankenGrotesk(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "File berhasil dipilih",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _clearFile, 
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_rounded, color: AppColors.neonCyan, size: 32),
                const SizedBox(height: 8),
                Text(
                  "Tap untuk upload Bukti (JPG/PDF)",
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.buttonGradientTop, AppColors.buttonGradientBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonBlack.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 0,
            offset: const Offset(0, 1),
            spreadRadius: 0,
            blurStyle: BlurStyle.inner
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // --- PANGGIL FUNGSI _submitData DI SINI ---
          onTap: _isLoading ? null : _submitData, 
          child: Center(
            child: _isLoading 
              ? const SizedBox(
                  height: 24, width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  "Kirim Pengajuan",
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
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