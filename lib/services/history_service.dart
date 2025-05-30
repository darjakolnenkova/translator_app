import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static final _firestore = FirebaseFirestore.instance;
  static final _user = FirebaseAuth.instance.currentUser;

  static Future<void> saveTranslation(String original, String translated) async {
    if (_user == null) return;
    await _firestore.collection('users')
        .doc(_user!.uid)
        .collection('translations')
        .add({
      'original': original,
      'translated': translated,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, String>>> loadCloudHistory() async {
    if (_user == null) return [];
    final snapshots = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('translations')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshots.docs.map((doc) => {
      'original': doc['original'] as String,
      'translated': doc['translated'] as String,
    }).toList();
  }
}