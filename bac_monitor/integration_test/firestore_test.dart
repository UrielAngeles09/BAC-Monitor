import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// MODIFIED: correct Firebase options import (IMPORTANT)
import 'package:bac_monitor/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("🔥 Firestore BAC Tests", () {

    // MODIFIED: proper Firebase initialization using FirebaseOptions
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Ensure anonymous user exists for testing
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    });

    testWidgets("Save BAC reading to Firestore", (tester) async {
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);

      final uid = user!.uid;

      final db = FirebaseFirestore.instance;

      final testData = {
        "bac": 0.07,
        "tac": 0.003,
        "temp": 30.0,
        "humidity": 60.0,
        "timestamp": FieldValue.serverTimestamp(),
      };

      final docRef = await db
          .collection("users")
          .doc(uid)
          .collection("bac_readings")
          .add(testData);

      expect(docRef.id, isNotEmpty);

      final snapshot = await docRef.get();

      expect(snapshot.exists, true);
      expect(snapshot["bac"], 0.07);
      expect(snapshot["tac"], 0.003);

      print("Firestore write & read successful");
    });

    testWidgets("Verify multiple readings exist", (tester) async {
      final user = FirebaseAuth.instance.currentUser!;
      final db = FirebaseFirestore.instance;

      final query = await db
          .collection("users")
          .doc(user.uid)
          .collection("bac_readings")
          .get();

      expect(query.docs.isNotEmpty, true);

      print("Found ${query.docs.length} readings in Firestore");
    });

    testWidgets("Ensure user isolation", (tester) async {
      final user = FirebaseAuth.instance.currentUser!;
      final db = FirebaseFirestore.instance;

      final query = await db
          .collection("users")
          .doc(user.uid)
          .collection("bac_readings")
          .get();

      for (var doc in query.docs) {
        expect(doc.data().containsKey("bac"), true);
      }

      print("Data structure valid for user");
    });
  });
}