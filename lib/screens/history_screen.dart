import 'package:flutter/material.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: HistoryService.loadCloudHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final translations = snapshot.data as List<Map<String, String>>;
        if (translations.isEmpty) {
          return const Center(
            child: Text(
              "No translation history yet.",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: translations.length,
          itemBuilder: (context, index) {
            final item = translations[index];
            return ListTile(
              leading: const Icon(Icons.translate, color: Color(0xFFEF5350)),
              title: Text(item['original'] ?? ''),
              subtitle: Text(item['translated'] ?? ''),
            );
          },
        );
      },
    );
  }
}
