import 'package:flutter/material.dart';

void alertOrder({
  required String title,
  required String productName,
  bool? isScanned,
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
}) {
  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          icon: Icon(icon, color: iconColor, size: 50),
          title: Text(title),
          content: Text(productName),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                isScanned = false;
              },
              child: const Text('OK'),
            ),
          ],
        ),
  );
}
