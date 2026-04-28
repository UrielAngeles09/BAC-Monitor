import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bac_monitor/services/database_service.dart'; 

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text(
          "History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.getReadings(), //
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No data yet"));
                }

                final readings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: readings.length,
                  itemBuilder: (context, index) {
                    final data = readings[index];

                    final timestamp =
                        (data["timestamp"] as Timestamp?)?.toDate();

                    return HistoryItem(
                      date: timestamp != null
                          ? "${timestamp.month}/${timestamp.day}/${timestamp.year}"
                          : "No date",
                      time: timestamp != null
                          ? "${timestamp.hour}:${timestamp.minute}"
                          : "No time",
                      bac:
                          "${(data["bac"] * 100).toStringAsFixed(2)}%", // 
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  final String date;
  final String time;
  final String bac;

  const HistoryItem({
    super.key,
    required this.date,
    required this.time,
    required this.bac,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.water_drop, color: Colors.red),
      title: Text(date),
      subtitle: Text(time),
      trailing: Text(
        "BAC: $bac",
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}