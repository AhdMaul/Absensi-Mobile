// lib/features/home/widgets/home_widgets.dart

import 'package:flutter/material.dart';

import 'home_content.dart';

// Thin wrapper kept for backwards compatibility.
// `HomeContent` contains the split components and controller-driven UI.
class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeContent();
  }
}