import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// AppSnackbar matches the project's snackbar style: colored but semi-transparent.
class AppSnackbar {
	/// Show a snackbar with a soft colored, semi-transparent background.
	/// [type] supports: 'info' (default), 'success', 'error', 'warning'.
	static void show(String title, String message, {String type = 'info'}) {
		Color bgColor;
		IconData iconData;

		switch (type) {
			case 'error':
				bgColor = AppColors.error.withValues(alpha: 0.18);
				iconData = Icons.error;
				break;
			case 'success':
				bgColor = AppColors.neonGreen.withValues(alpha: 0.18);
				iconData = Icons.check_circle;
				break;
					case 'warning':
						bgColor = Colors.orange.withValues(alpha: 0.18);
						iconData = Icons.warning;
						break;
			default:
				// info
				bgColor = AppColors.neonCyan.withValues(alpha: 0.18);
				iconData = Icons.info;
		}

		Get.snackbar(
			title,
			message,
			snackPosition: SnackPosition.BOTTOM,
			snackStyle: SnackStyle.FLOATING,
			backgroundColor: bgColor,
			// Use primary text color so the message remains readable on soft backgrounds
			colorText: AppColors.textPrimary,
			margin: const EdgeInsets.all(16),
			borderRadius: 12,
			icon: Icon(
				iconData,
				color: // make icon pop a bit more than background
						(type == 'error')
								? AppColors.error.withValues(alpha: 0.9)
								: (type == 'success')
										? AppColors.neonGreen.withValues(alpha: 0.9)
										: AppColors.neonCyan.withValues(alpha: 0.9),
			),
			duration: const Duration(seconds: 3),
		);
	}
}
