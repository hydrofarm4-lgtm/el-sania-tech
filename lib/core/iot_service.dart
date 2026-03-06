import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../l10n/app_localizations.dart';

class CropProfile {
  final String id;
  final String name;
  final double minTemp;
  final double maxTemp;
  final double minHumidity;
  final double maxHumidity;
  final double minPh;
  final double maxPh;

  const CropProfile({
    required this.id,
    required this.name,
    required this.minTemp,
    required this.maxTemp,
    required this.minHumidity,
    required this.maxHumidity,
    required this.minPh,
    required this.maxPh,
  });

  factory CropProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CropProfile(
      id: doc.id,
      name: data['name'] ?? '',
      minTemp: (data['minTemp'] ?? 0.0).toDouble(),
      maxTemp: (data['maxTemp'] ?? 0.0).toDouble(),
      minHumidity: (data['minHumidity'] ?? 0.0).toDouble(),
      maxHumidity: (data['maxHumidity'] ?? 0.0).toDouble(),
      minPh: (data['minPh'] ?? 0.0).toDouble(),
      maxPh: (data['maxPh'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'minPh': minPh,
      'maxPh': maxPh,
    };
  }
}

class WorkerSession {
  final String workerId;
  final String greenhouseId;
  final DateTime startTime;

  WorkerSession({
    required this.workerId,
    required this.greenhouseId,
    required this.startTime,
  });
}

class IoTService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Map<String, int> _dangerTimers = {};
  Map<String, WorkerSession> _activeSessions = {};
  List<CropProfile> _cachedCrops = [];

  IoTService() {
    _initNotifications();
    _startMonitoring();
    _listenToCrops();
  }

  Map<String, WorkerSession> get activeSessions => _activeSessions;
  List<CropProfile> get cachedCrops => _cachedCrops;

  void _listenToCrops() {
    _firestore.collection('crops_settings').snapshots().listen((snapshot) {
      _cachedCrops = snapshot.docs
          .map((doc) => CropProfile.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  Stream<List<CropProfile>> get cropsStream => _firestore
      .collection('crops_settings')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => CropProfile.fromFirestore(doc)).toList(),
      );

  Future<void> addCrop(CropProfile crop) async {
    await _firestore.collection('crops_settings').add(crop.toMap());
  }

  Future<void> updateCrop(CropProfile crop) async {
    await _firestore
        .collection('crops_settings')
        .doc(crop.id)
        .update(crop.toMap());
  }

  Future<void> deleteCrop(String id) async {
    await _firestore.collection('crops_settings').doc(id).delete();
  }

  Future<void> setActiveCrop(String houseId, String cropId) async {
    await _firestore.collection('greenhouses').doc(houseId).update({
      'activeCropId': cropId,
    });
  }

  Stream<Map<String, WorkerSession>> get sessionStream => _firestore
      .collection('sessions')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) {
        final Map<String, WorkerSession> sessions = {};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final workerId = data['workerId'] as String;
          sessions[workerId] = WorkerSession(
            workerId: workerId,
            greenhouseId: data['greenhouseId'] as String,
            startTime: (data['startTime'] as Timestamp).toDate(),
          );
        }
        _activeSessions = sessions;
        return sessions;
      });

  Future<void> startSession(String workerId, String houseId) async {
    await _firestore.collection('sessions').doc(workerId).set({
      'workerId': workerId,
      'greenhouseId': houseId,
      'startTime': FieldValue.serverTimestamp(),
      'status': 'active',
    });
  }

  Future<void> endSession(String workerId) async {
    await _firestore.collection('sessions').doc(workerId).update({
      'status': 'completed',
      'endTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleActuator(String houseId, String key, bool value) async {
    await _firestore.collection('greenhouses').doc(houseId).update({
      'actuators.$key': value,
    });
  }

  Future<void> updateTargetRange(String houseId, double min, double max) async {
    await _firestore.collection('greenhouses').doc(houseId).update({
      'targetMin': min,
      'targetMax': max,
    });
  }

  Future<void> updateMode(String houseId, String mode) async {
    await _firestore.collection('greenhouses').doc(houseId).update({
      'mode': mode,
    });
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  void _startMonitoring() {
    _firestore.collection('greenhouses').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final houseId = doc.id;
        final healthScore = calculateHealthScore(data);

        if (healthScore < 40) {
          _dangerTimers[houseId] = (_dangerTimers[houseId] ?? 0) + 1;
          if (_dangerTimers[houseId] == 10) {
            _showDangerNotification(houseId, healthScore);
          }
        } else {
          _dangerTimers[houseId] = 0;
        }
      }
    });
  }

  Future<void> _showDangerNotification(String houseId, double score) async {
    const android = AndroidNotificationDetails(
      'danger_zone',
      'Danger Alerts',
      channelDescription: 'Critical alerts for smart farm',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _notifications.show(
      id: DateTime.now().millisecond % 100000,
      title: 'CRITICAL ALERT: $houseId',
      body:
          'Health Score dropped to ${score.toStringAsFixed(0)}%. Immediate action required.',
      notificationDetails: const NotificationDetails(android: android),
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> greenhouseStream(String id) {
    return _firestore.collection('greenhouses').doc(id).snapshots();
  }

  double calculateHealthScore(Map<String, dynamic> data) {
    final activeCropId = data['activeCropId'];
    CropProfile? activeCrop;

    if (activeCropId != null) {
      try {
        activeCrop = _cachedCrops.firstWhere((c) => c.id == activeCropId);
      } catch (e) {
        activeCrop = null;
      }
    }

    // Default values if no active crop
    final double minTemp = activeCrop?.minTemp ?? 18.0;
    final double maxTemp = activeCrop?.maxTemp ?? 28.0;
    final double minHum = activeCrop?.minHumidity ?? 50.0;
    final double maxHum = activeCrop?.maxHumidity ?? 80.0;
    final double minPh = activeCrop?.minPh ?? 5.5;
    final double maxPh = activeCrop?.maxPh ?? 7.0;

    final temp = (data['temperature'] ?? 22.0).toDouble();
    final hum = (data['humidity'] ?? 70.0).toDouble();
    final ph = (data['ph'] ?? 6.0).toDouble();

    double score = 100.0;

    if (temp < minTemp) score -= (minTemp - temp) * 8;
    if (temp > maxTemp) score -= (temp - maxTemp) * 8;

    if (hum < minHum) score -= (minHum - hum) * 3;
    if (hum > maxHum) score -= (hum - maxHum) * 3;

    if (ph < minPh) score -= (minPh - ph) * 25;
    if (ph > maxPh) score -= (ph - maxPh) * 25;

    return score.clamp(0.0, 100.0);
  }

  String getAIInsight(double healthScore, AppLocalizations l10n) {
    if (healthScore > 90) return l10n.aiInsightPerfect;
    if (healthScore > 75) return l10n.aiInsightGood;
    if (healthScore > 40) return l10n.aiInsightWarning;
    return l10n.aiInsightDanger;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTrendData(String houseId) {
    return _firestore
        .collection('greenhouses')
        .doc(houseId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(24)
        .snapshots();
  }
}
