import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> history = [];
  List<Map<String, String>> filteredHistory = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  /// Loads history from SharedPreferences.
  /// If empty, store and load two default demo readings.
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString("bac_history");

  List<Map<String, String>> demo = [
      {
        "date": "Nov 7, 2025",
        "time": "04:55 pm",
        "bac": "10%",
      },
      {
        "date": "Sep 8, 2025",
        "time": "06:05 pm",
        "bac": "6%",
      },
    ];

  

    // Save updated list
    await prefs.setString("bac_history", jsonEncode(history));
    history = demo;

    setState(() {
      filteredHistory = history;
    });
  }

  /// Filter search results
  void searchHistory(String query) {
    query = query.toLowerCase();

    setState(() {
      filteredHistory = history.where((item) {
        return item["date"]!.toLowerCase().contains(query) ||
            item["time"]!.toLowerCase().contains(query) ||
            item["bac"]!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text("History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey.shade200,
            child: TextField(
              onChanged: searchHistory,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search by date or BAC %",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
          ),

          // HISTORY LIST
          Expanded(
            child: filteredHistory.isEmpty
                ? const Center(
                    child: Text("No results found"),
                  )
                : ListView.builder(
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = filteredHistory[index];
                      return HistoryItem(
                        date: item["date"]!,
                        time: item["time"]!,
                        bac: item["bac"]!,
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
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
