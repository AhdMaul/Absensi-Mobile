// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/home_widgets.dart';
import '../../auth/services/auth_service.dart'; // Import AuthService untuk logout (jika perlu)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Fungsi logout (jika ingin ditaruh di AppBar Home)
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (confirm == true && context.mounted) {
      await AuthService().logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda ESHRM'),
        automaticallyImplyLeading: false,
        actions: [
        ],
      ),
      body: const HomeWidget(),
    );
  }
}