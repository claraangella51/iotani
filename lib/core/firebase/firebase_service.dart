import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Initialize Firebase - call this in main() before runApp()
Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Auth methods
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Database methods - Device State
  Future<void> setDeviceState({
    required String deviceId,
    required Map<String, dynamic> state,
  }) async {
    await _database.ref('devices/$deviceId/state').set(state);
  }

  Stream<Map<String, dynamic>?> streamDeviceState(String deviceId) {
    return _database.ref('devices/$deviceId/state').onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  // Database methods - Sensor Readings
  Future<void> addSensorReading({
    required String deviceId,
    required Map<String, dynamic> reading,
  }) async {
    final key = _database.ref('sensor_readings/$deviceId').push().key;
    await _database.ref('sensor_readings/$deviceId/$key').set({
      ...reading,
      'id': key,
      'deviceId': deviceId,
    });
  }

  Stream<List<Map<String, dynamic>>> streamRecentReadings(
    String deviceId, {
    int limit = 20,
  }) {
    return _database
        .ref('sensor_readings/$deviceId')
        .orderByChild('timestamp')
        .limitToLast(limit)
        .onValue
        .map((event) {
          if (event.snapshot.exists) {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            return data.entries
                .map((e) => Map<String, dynamic>.from(e.value as Map))
                .toList()
                .reversed
                .toList();
          }
          return [];
        });
  }

  // Database methods - Commands
  Future<void> sendCommand({
    required String deviceId,
    required String actionType, // 'pump', 'uv_lamp', 'mode'
    required String target,
    required bool value,
  }) async {
    final key = _database.ref('commands/$deviceId').push().key;
    await _database.ref('commands/$deviceId/$key').set({
      'id': key,
      'actionType': actionType,
      'target': target,
      'value': value,
      'status': 'pending',
      'createdAt': ServerValue.timestamp,
      'executedAt': null,
    });
  }

  Stream<List<Map<String, dynamic>>> streamCommandStatus(String deviceId) {
    return _database.ref('commands/$deviceId').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data.entries
            .map((e) => Map<String, dynamic>.from(e.value as Map))
            .toList();
      }
      return [];
    });
  }

  // Database methods - Alerts
  Future<void> addAlert({
    required String userId,
    required String title,
    required String message,
    required String riskStatus,
  }) async {
    final key = _database.ref('alerts/$userId').push().key;
    await _database.ref('alerts/$userId/$key').set({
      'id': key,
      'title': title,
      'message': message,
      'riskStatus': riskStatus,
      'read': false,
      'createdAt': ServerValue.timestamp,
    });
  }

  Stream<List<Map<String, dynamic>>> streamAlerts(String userId) {
    return _database
        .ref('alerts/$userId')
        .orderByChild('createdAt')
        .onValue
        .map((event) {
          if (event.snapshot.exists) {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            return data.entries
                .map((e) => Map<String, dynamic>.from(e.value as Map))
                .toList()
                .reversed
                .toList();
          }
          return [];
        });
  }

  Future<void> markAlertAsRead(String userId, String alertId) async {
    await _database.ref('alerts/$userId/$alertId/read').set(true);
  }

  // User profile
  Future<void> setUserProfile({
    required String userId,
    required Map<String, dynamic> profile,
  }) async {
    await _database.ref('users/$userId').update(profile);
  }

  Stream<Map<String, dynamic>?> streamUserProfile(String userId) {
    return _database.ref('users/$userId').onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  // Push Notifications
  Future<String?> getDeviceToken() async {
    return await _messaging.getToken();
  }

  Future<void> initializeMessaging() async {
    // Permission request
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the message
    });

    // Handle background message
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap
    });
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
