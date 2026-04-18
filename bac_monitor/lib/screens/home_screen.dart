import 'package:flutter/material.dart';
import 'live_bac_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'package:bac_monitor/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text("Menu"),
                    content: const Text("Do you want to sign out?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);

                          Navigator.pop(dialogContext);

                          print("=== SIGN OUT STARTED ===");

                          try {
                            await auth.signOut();
                            print("=== SIGN OUT SUCCESS ===");
                          } catch (e) {
                            print("=== SIGN OUT ERROR: $e ===");
                          }

                          print("=== NAVIGATING TO LOGIN ===");

                          navigator.pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );

                          print("=== NAVIGATION CALLED ===");
                        },
                        child: const Text("Sign Out"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveBACScreen()),
                );
              },
              child: const Text(
                "Live BAC",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              child: const Text(
                "History",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}