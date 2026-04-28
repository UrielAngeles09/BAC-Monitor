import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // SAVE BAC READING
  Future<void> saveReading({
    required double bac,
    required double tac,
    required double temp,
    required double humidity,
  }) async {
    if (uid == null) return;

    await _db
        .collection("users")
        .doc(uid)
        .collection("bac_readings")
        .add({
      "bac": bac,
      "tac": tac,
      "temp": temp,
      "humidity": humidity,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  // STREAM READINGS
  Stream<QuerySnapshot> getReadings() {
    if (uid == null) throw Exception("User not logged in");

    return _db
        .collection("users")
        .doc(uid)
        .collection("bac_readings")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}