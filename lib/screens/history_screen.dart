import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Stream<List<Map<String, dynamic>>> _historyStream;

  @override
  void initState() {
    super.initState();
    _initializeHistory();
  }

  void _initializeHistory() {
    setState(() {
      _historyStream = HistoryService.getHistoryStream();
    });
  }

  Future<void> _refreshHistory() async {
    _initializeHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshHistory,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _historyStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorWidget(
                snapshot.error.toString(),
                isDarkMode,
                onRetry: _refreshHistory,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final translations = snapshot.data ?? [];
            if (translations.isEmpty) {
              return _buildEmptyHistoryWidget(isDarkMode);
            }

            return _buildHistoryList(translations, isDarkMode);
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, bool isDarkMode, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load history',
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryWidget(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No translation history yet.',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildHistoryList(List<Map<String, dynamic>> translations, bool isDarkMode) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: translations.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
      itemBuilder: (context, index) {
        final item = translations[index];
        final date = item['timestamp'] as DateTime;
        return _buildHistoryItem(item, date, isDarkMode);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, DateTime date, bool isDarkMode) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['original'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['translated'] ?? '',
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item['fromLang']?.toString().toUpperCase() ?? 'EN'} → '
                        '${item['toLang']?.toString().toUpperCase() ?? 'FR'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MMM dd, HH:mm').format(date),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}