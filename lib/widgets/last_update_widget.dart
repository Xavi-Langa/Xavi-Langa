import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:daily_sales/services/firestore_service.dart'; // Firestore service
import 'package:daily_sales/utils/utils.dart'; // Utils for formatting

class LastUpdateWidget extends StatelessWidget {
  const LastUpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirestoreService().getLastUpdateStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Atualizando...');
        }
        final lastUpdate = snapshot.data!;
        final formattedDate = Utils.formatDateTime(
            (lastUpdate['last_run'] as Timestamp).toDate());

        return Row(
          children: [
            const Icon(
              Icons.access_time, // Clock icon representing last update
              size: 16,          // Adjust the icon size
              color: Colors.blueGrey, // Optional: set the color
            ),
            const SizedBox(width: 4), // Add some space between the icon and text
            Text(
              'Last update: $formattedDate',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      },
    );
  }
}
