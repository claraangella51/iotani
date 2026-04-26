#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>

// ================= WIFI =================
#define WIFI_SSID "Blue House"
#define WIFI_PASSWORD "DANGER06"

// ================= FIREBASE =================
#define API_KEY "AIzaSyBG-QC7WErOHPtSzwmAGlMikp6cSAXcvLY"
#define DATABASE_URL "https://iotani-kelompok3-default-rtdb.asia-southeast1.firebasedatabase.app/"

// ================= PIN =================
#define SOIL A0
#define LDR D2

#define RELAY_POMPA D1
#define RELAY_LAMPU D5

#define RELAY_ACTIVE_LOW true

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

bool pumpState = false;
bool lampState = false;

unsigned long lastSend = 0;
const unsigned long interval = 5000;

// ================= RELAY =================
void writeRelay(uint8_t pin, bool state) {
  digitalWrite(pin, RELAY_ACTIVE_LOW ? !state : state);
}

// ================= SENSOR =================
int readSoil() {
  int raw = analogRead(SOIL);
  int moisture = map(raw, 1024, 0, 0, 100);
  return constrain(moisture, 0, 100);
}

int readLight() {
  return digitalRead(LDR) == LOW ? 100 : 1000; // sesuaikan
}

// ================= WIFI =================
void connectWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi Connected");
}

// ================= SETUP =================
void setup() {
  Serial.begin(115200);

  pinMode(LDR, INPUT);
  pinMode(RELAY_POMPA, OUTPUT);
  pinMode(RELAY_LAMPU, OUTPUT);

  writeRelay(RELAY_POMPA, false);
  writeRelay(RELAY_LAMPU, false);

  connectWiFi();

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

// ================= LOOP =================
void loop() {

  // ===== KIRIM SENSOR =====
  if (millis() - lastSend >= interval) {
    lastSend = millis();

    int kelembapan = readSoil();
    int cahaya = readLight();

    Serial.println("Kirim sensor:");
    Serial.println(kelembapan);
    Serial.println(cahaya);

    Firebase.RTDB.setInt(&fbdo, "/iotani/sensor/kelembapan", kelembapan);
    Firebase.RTDB.setInt(&fbdo, "/iotani/sensor/cahaya", cahaya);
    Firebase.RTDB.setInt(&fbdo, "/iotani/sensor/plantIndex", 0);
  }

  // ===== BACA CONTROL (STRING ON/OFF) =====
  if (Firebase.RTDB.getString(&fbdo, "/iotani/control/pompa")) {
    String val = fbdo.stringData();
    pumpState = (val == "ON");
    writeRelay(RELAY_POMPA, pumpState);
  }

  if (Firebase.RTDB.getString(&fbdo, "/iotani/control/lampu")) {
    String val = fbdo.stringData();
    lampState = (val == "ON");
    writeRelay(RELAY_LAMPU, lampState);
  }

  delay(500);
}