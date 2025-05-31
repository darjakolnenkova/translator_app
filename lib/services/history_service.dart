import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class HistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _isSaving = false;
  static final Set<String> _pendingTranslations = {};

  // Сохранение перевода в историю
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

  // Полная очистка истории переводов
  static Future<void> clearAllHistory() async {
    try {
      debugPrint('🧹 Starting to clear all history...');

      // Получаем все документы пачками по 100
      QuerySnapshot snapshot;
      int totalDeleted = 0;
      final batchSize = 100;

      do {
        snapshot = await _firestore
            .collection('translations')
            .limit(batchSize)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          totalDeleted += snapshot.docs.length;
          debugPrint('🗑 Deleted ${snapshot.docs.length} items (total: $totalDeleted)');
        }
      } while (snapshot.docs.length == batchSize);

      debugPrint('✅ Successfully cleared all history ($totalDeleted items)');
    } catch (e) {
      debugPrint('❌ Error clearing history: $e');
      throw Exception('Failed to clear history: $e');
    }
  }

  // Загрузка истории (разовое получение)
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

  // Поток для实时 обновления истории
  static Stream<List<Map<String, dynamic>>> getHistoryStream() {
    return _firestore
        .collection('translations')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => _processDocuments(snapshot.docs))
        .map((data) {
      // Фильтрация дубликатов
      final seen = <String>{};
      return data.where((item) {
        final id = item['id'] as String;
        return seen.add(id);
      }).toList();
    })
        .handleError((error) {
      debugPrint('Stream error: $error');
      return <Map<String, dynamic>>[];
    });
  }

  // Обработка документов Firestore
  static List<Map<String, dynamic>> _processDocuments(
      List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp?;

      return {
        'id': doc.id,
        'original': data['original']?.toString().trim() ?? '',
        'translated': data['translated']?.toString().trim() ?? '',
        'fromLang': data['fromLang']?.toString() ?? 'en',
        'toLang': data['toLang']?.toString() ?? 'fr',
        'timestamp': timestamp?.toDate() ?? DateTime.now(),
      };
    }).toList();
  }

  static Future<void> deleteTranslation(String id) async {
    try {
      await _firestore.collection('translations').doc(id).delete();
      debugPrint('🗑 Deleted translation: $id');
    } catch (e) {
      debugPrint('❌ Error deleting translation: $e');
      throw Exception('Failed to delete translation: $e');
    }
  }
}