import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bac_monitor/services/database_service.dart';



class LiveBACScreen extends StatefulWidget {
  const LiveBACScreen({super.key});

  @override
  State<LiveBACScreen> createState() => _LiveBACScreenState();
}

class _LiveBACScreenState extends State<LiveBACScreen> {
  double bac = 0.0;
  double tac = 0.0;
  double temp = 0.0;
  double humidity = 0.0;
  DateTime lastSaved = DateTime.now();
  final DatabaseService db = DatabaseService();

  final Guid serviceUuid = Guid("12345678-1234-1234-1234-1234567890ab");
  final Guid characteristicUuid = Guid("abcd1234-5678-1234-5678-abcdef123456");

  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? targetCharacteristic;

  @override
  void initState() {
    super.initState();
    requestPermissionsAndScan();
  }

  Future<void> requestPermissionsAndScan() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    startScan();
  }

  void startScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name == "ESP32-S3 Sensor") {
          targetDevice = r.device;
          await FlutterBluePlus.stopScan();
          await connectToDevice();
          break;
        }
      }
    });
  }

  Future<void> connectToDevice() async {
    if (targetDevice == null) return;

    try {
      await targetDevice!.connect(autoConnect: false);
      List<BluetoothService> services = await targetDevice!.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid == serviceUuid) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid == characteristicUuid) {
              targetCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                try {
                  String jsonString = utf8.decode(value);
                  final data = jsonDecode(jsonString);
                  setState(() {
                    temp = (data["temp"] ?? 0).toDouble();
                    humidity = (data["humidity"] ?? 0).toDouble();
                    tac = (data["current"] ?? 0).toDouble();
                    bac = tac * 20;
                  });

                      // SAVE TO FIRESTORE
                  if (DateTime.now().difference(lastSaved).inSeconds > 10) { // ✅ ADDED
                    db.saveReading(
                      bac: bac,
                      tac: tac,
                      temp: temp,
                      humidity: humidity,
                    );

                    lastSaved = DateTime.now();
                  }


                } catch (e) {
                  debugPrint("JSON Error: $e");
                }
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error connecting to device: $e");
    }
  }

  @override
  void dispose() {
    targetDevice?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text("Live BAC",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("Today", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          AnimatedPercentageCircle(percent: bac, size: 220, color: Colors.red, label: "${(bac * 100).toStringAsFixed(1)}%"),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedPercentageCircle(percent: tac, size: 90, color: Colors.blue, label: "${(tac * 100).toStringAsFixed(1)}%", subtitle: "TAC"),
              AnimatedPercentageCircle(percent: temp, size: 90, color: Colors.orange, label: "${(temp * 100).toStringAsFixed(1)}%", subtitle: "Temp"),
              AnimatedPercentageCircle(percent: humidity, size: 90, color: Colors.green, label: "${(humidity * 100).toStringAsFixed(1)}%", subtitle: "Humidity"),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedPercentageCircle extends StatelessWidget {
  final double percent;
  final double size;
  final Color color;
  final String label;
  final String? subtitle;

  const AnimatedPercentageCircle({
    super.key,
    required this.percent,
    required this.size,
    required this.color,
    required this.label,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: percent),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: value.clamp(0.0, 1.0),
                      strokeWidth: size * 0.08,
                      color: color,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: size * 0.18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}