import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class HistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _isSaving = false;
  static final Set<String> _pendingTranslations = {};

  static Future<void> saveTranslation({
    required String original,
    required String translated,
    String fromLang = 'en',
    String toLang = 'fr',
  }) async {
    final translationKey = '$original-$translated-$fromLang-$toLang';

    if (_isSaving || _pendingTranslations.contains(translationKey)) {
      debugPrint('⏭ Translation is already being saved: $translationKey');
      return;
    }

    _isSaving = true;
    _pendingTranslations.add(translationKey);

    try {
      final existingQuery = await _firestore
          .collection('translations')
          .where('original', isEqualTo: original)
          .where('translated', isEqualTo: translated)
          .where('fromLang', isEqualTo: fromLang)
          .where('toLang', isEqualTo: toLang)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        debugPrint('⏭ Translation already exists in database');
        return;
      }

      debugPrint('💾 Saving translation: $original → $translated');
      await _firestore.collection('translations').add({
        'original': original.trim(),
        'translated': translated.trim(),
        'fromLang': fromLang,
        'toLang': toLang,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Translation saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving translation: $e');
      throw Exception('Failed to save translation: $e');
    } finally {
      _isSaving = false;
      _pendingTranslations.remove(translationKey);
    }
  }

  static Future<List<Map<String, dynamic>>> loadCloudHistory() async {
    try {
      final snapshot = await _firestore
          .collection('translations')
          .orderBy('timestamp', descending: true)
          .get();

      return _processDocuments(snapshot.docs);
    } catch (e) {
      debugPrint('Error loading history: $e');
      throw Exception('Failed to load history: $e');
    }
  }

  static Stream<List<Map<String, dynamic>>> getHistoryStream() {
    return _firestore
        .collection('translations')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => _processDocuments(snapshot.docs))
        .map((data) {
      // Фильтрация дубликатов по 'id'
      final seen = <String>{};
      final distinctData = data.where((item) {
        final id = item['id'] as String;
        if (seen.contains(id)) {
          return false; // Пропускаем дублирующиеся записи
        } else {
          seen.add(id);
          return true;
        }
      }).toList();

      return distinctData;
    })
        .handleError((error) {
      debugPrint('Stream error: $error');
      return <Map<String, dynamic>>[]; // Пустой список при ошибке
    });
  }

  static List<Map<String, dynamic>> _processDocuments(
      List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return {
        'id': doc.id,
        'original': data['original']?.toString().trim() ?? '',
        'translated': data['translated']?.toString().trim() ?? '',
        'fromLang': data['fromLang']?.toString() ?? 'en',
        'toLang': data['toLang']?.toString() ?? 'fr',
        'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      };
    }).toList();
  }
}
