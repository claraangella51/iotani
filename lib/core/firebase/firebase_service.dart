import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/plant_profile.dart';
import 'package:iotani_berhasil/features/monitoring/domain/models/sensor_reading.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // =========================
  // AUTH
  // =========================

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<void> setUserProfile({
    required String userId,
    required Map<String, dynamic> profile,
  }) {
    return _db.ref('users/$userId').set(profile);
  }

  User? get user => _auth.currentUser;

  // =========================
  // IOTANI STREAM (REALTIME)
  // =========================

  Stream<Map<String, dynamic>?> streamIoTani() {
    return streamDeviceState('device_001');
  }

  Stream<Map<String, dynamic>?> streamDeviceState(String deviceId) {
    return _db.ref('iotani/status').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return null;
      }

      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      return _normalizeStatusMap(raw, deviceId: deviceId);
    });
  }

  Stream<List<SensorReading>> streamRecentReadings(String deviceId) {
    return _db.ref('iotani/sensor').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <SensorReading>[];
      }

      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final reading = _normalizeSensorReadingMap(raw, deviceId: deviceId);
      return [SensorReading.fromRealtimeDb(reading)];
    });
  }

  // =========================
  // CONTROL MODE
  // =========================

  Future<void> setMode(String mode) async {
    final normalizedMode = _normalizeMode(mode);
    await _db.ref('iotani/control/mode').set(normalizedMode);
  }

  Future<void> setAutoPlantProfile(PlantProfile plant) async {
    final soilSpan = (plant.soilMoistureMax - plant.soilMoistureMin).abs();
    final lightSpan = (plant.lightLuxMax - plant.lightLuxMin).abs();

    // Soil is expressed in %, so keep fuzzy band small and responsive.
    final soilFuzzyBand = soilSpan <= 0
        ? 10
        : (soilSpan / 2).round().clamp(10, 30);

    // Light is in lux and much wider; use a proportional band with sane floor.
    final lightFuzzyBand = lightSpan <= 0
        ? 100
        : (lightSpan * 0.15).round().clamp(50, 2000);

    final profile = <String, dynamic>{
      'id': plant.id,
      'name': plant.name,
      'category': plant.category,
      'soilMin': plant.soilMoistureMin,
      'soilMax': plant.soilMoistureMax,
      'lightMin': plant.lightLuxMin,
      'lightMax': plant.lightLuxMax,
      'soilFuzzyBand': soilFuzzyBand,
      'lightFuzzyBand': lightFuzzyBand,
      'updatedAt': ServerValue.timestamp,
    };

    await _db.ref('iotani/control/plantProfile').set(profile);
  }

  // =========================
  // MANUAL CONTROL
  // =========================

  Future<void> setPompa(bool isOn) async {
    await _db.ref('iotani/manual/pompa').set(isOn ? 'ON' : 'OFF');
  }

  Future<void> setLampu(bool isOn) async {
    await _db.ref('iotani/manual/lampu').set(isOn ? 'ON' : 'OFF');
  }

  Future<void> sendCommand({
    required String deviceId,
    required String actionType,
    required String target,
    required bool value,
  }) async {
    switch (target) {
      case 'mode':
        await setMode(value ? 'manual' : 'auto');
        return;
      case 'pump':
        await setPompa(value);
        return;
      case 'uv_lamp':
        await setLampu(value);
        return;
      default:
        throw FirebaseException(
          plugin: 'firebase_database',
          message: 'Target command tidak dikenali: $target',
        );
    }
  }

  Map<String, dynamic> _normalizeStatusMap(
    Map<String, dynamic> data, {
    required String deviceId,
  }) {
    final map = Map<String, dynamic>.from(data);

    map['deviceId'] = (map['deviceId'] as String?) ?? deviceId;
    map['soilMoisture'] = map['soilMoisture'] ?? map['kelembapan'] ?? 0;
    map['lightLux'] = map['lightLux'] ?? map['cahaya'] ?? 0;
    map['riskStatus'] = map['riskStatus'] ?? 'aman';
    map['mode'] = _normalizeMode(map['mode'] as String?);
    map['pumpStatus'] = _toBool(map['pumpStatus'] ?? map['pompa']);
    map['uvLampStatus'] = _toBool(map['uvLampStatus'] ?? map['lampu']);
    map['lastUpdated'] =
        map['lastUpdated'] ??
        map['lastUpdate'] ??
        DateTime.now().millisecondsSinceEpoch;
    map['isConnected'] = map['isConnected'] ?? true;

    final plant = map['plant'];
    if (plant is Map) {
      map['plant'] = Map<String, dynamic>.from(plant);
    }

    return map;
  }

  Map<String, dynamic> _normalizeSensorReadingMap(
    Map<String, dynamic> data, {
    required String deviceId,
  }) {
    final map = Map<String, dynamic>.from(data);

    map['id'] = (map['id'] as String?) ?? 'latest';
    map['deviceId'] = (map['deviceId'] as String?) ?? deviceId;
    map['soilMoisture'] = map['soilMoisture'] ?? map['kelembapan'] ?? 0;
    map['lightLux'] = map['lightLux'] ?? map['cahaya'] ?? 0;
    map['riskStatus'] = map['riskStatus'] ?? 'aman';
    map['timestamp'] =
        map['timestamp'] ??
        map['lastUpdate'] ??
        DateTime.now().millisecondsSinceEpoch;

    return map;
  }

  String _normalizeMode(String? mode) {
    switch (mode) {
      case 'manual':
        return 'manual';
      case 'auto':
      case 'otomatis':
      default:
        return 'auto';
    }
  }

  bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'on' || normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
