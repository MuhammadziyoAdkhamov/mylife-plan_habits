import 'package:cloud_firestore/cloud_firestore.dart';

class CloudSyncService {
  CloudSyncService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _appStateDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('app_state')
        .doc('main');
  }

  Future<Map<String, dynamic>?> loadAppData(String uid) async {
    final snapshot = await _appStateDoc(uid).get();
    final docData = snapshot.data();

    if (!snapshot.exists || docData == null) return null;

    final rawData = docData['data'];
    if (rawData is! Map) return null;

    return Map<String, dynamic>.from(rawData);
  }

  Future<void> saveAppData(String uid, Map<String, dynamic> data) async {
    await _appStateDoc(uid).set(
      {
        'updatedAt': FieldValue.serverTimestamp(),
        'data': data,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteAppData(String uid) async {
    await _appStateDoc(uid).delete();
  }
}
