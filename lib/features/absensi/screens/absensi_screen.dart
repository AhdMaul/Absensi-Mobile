import 'package:flutter/material.dart';
import '../widgets/absensi_widgets.dart';

class AbsensiScreen extends StatelessWidget {
  const AbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Wajah Absensi'), 
        automaticallyImplyLeading: false,
      ),
      body: Center( 
        child: SingleChildScrollView(
           padding: const EdgeInsets.all(16.0),
           child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: const AbsenWidget(),
           ),
        ),
      ),
    );
  }
}