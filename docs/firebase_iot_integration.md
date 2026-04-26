# 🌿 IoTani - Smart Indoor Plant Monitoring System

IoTani adalah sistem monitoring dan kontrol tanaman berbasis IoT yang menggunakan **ESP8266/ESP32**, **Firebase Realtime Database**, dan **Flutter App**.

Sistem ini mampu:

* 📡 Monitoring kelembapan tanah & cahaya
* 🤖 Kontrol otomatis menggunakan **Fuzzy Logic**
* 🎛 Mode manual (kontrol pompa & lampu dari aplikasi)
* 📱 Dashboard realtime di Flutter

---

# 🧱 Arsitektur Sistem

```
ESP8266 / ESP32
        ↓
/iotani/sensor (Realtime Database)
        ↓
Cloud Function (Fuzzy Logic)
        ↓
/iotani/control & /iotani/status
        ↓
Flutter App (Realtime UI)
```

---

# 📂 Struktur Database (Realtime Database)

```
iotani/
  sensor/
    kelembapan: number
    cahaya: number
    plantIndex: number
    timestamp: number

  control/
    pompa: "ON" | "OFF"
    lampu: "ON" | "OFF"
    mode: "auto" | "manual"
    riskStatus: "aman" | "waspada" | "risiko_tinggi"
    pompaUpdatedAt: number
    lampuUpdatedAt: number

  manual/
    pompa: "ON" | "OFF"
    lampu: "ON" | "OFF"

  status/
    kelembapan: number
    cahaya: number
    pompa: "ON" | "OFF"
    lampu: "ON" | "OFF"
    riskStatus: string
    plant:
      name: string
      local_name: string
      scientific_name: string
    lightRequirement: string
    waterRequirement: string
    lastUpdate: number
```

---

# ⚙️ Cara Kerja Sistem

## 1. ESP8266 / ESP32

* Membaca sensor:

  * Soil Moisture
  * LDR (cahaya)
* Mengirim data ke:

```
/iotani/sensor
```

---

## 2. Cloud Function (Firebase)

* Trigger saat data sensor berubah
* Menggunakan:

  * Fuzzy Membership
  * Hysteresis
  * Delay (anti kedip)

### Output:

```
/iotani/control
/iotani/status
```

---

## 3. Flutter App

* Membaca data realtime dari:

```
/iotani/status
```

* Mengirim kontrol ke:

```
/iotani/manual
/iotani/control/mode
```

---

# 🤖 Fuzzy Logic

Sistem menggunakan:

* **Fuzzy Low** → kondisi kering / gelap
* **Fuzzy High** → kondisi basah / terang

### Contoh:

* Tanah kering → Pompa ON
* Cahaya kurang → Lampu ON

### Fitur tambahan:

* ✅ Hysteresis (biar tidak kedip)
* ✅ Minimum duration (delay 10 detik)
* ✅ Manual override

---

# 🎛 Mode Sistem

## 🔹 Auto Mode

* Dikontrol oleh Cloud Function (Fuzzy Logic)

## 🔹 Manual Mode

* Dikontrol langsung dari aplikasi Flutter
* Tidak dipengaruhi sensor

---

# 📱 Flutter Integration

## Realtime Stream

```dart
FirebaseDatabase.instance
  .ref("iotani/status")
  .onValue
```

---

## Control Manual

```dart
ref("iotani/manual/pompa").set("ON");
ref("iotani/manual/lampu").set("OFF");
```

---

# 🔌 ESP Setup

Isi konfigurasi:

* WiFi SSID & Password
* Firebase:

  * API_KEY
  * DATABASE_URL
  * Email & Password (Auth)

Library:

* `Firebase_ESP_Client`

---

# 🔐 Firebase Rules (Development)

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

---

# 🚀 Fitur Utama

* 🌿 Multi tanaman (berdasarkan `plantIndex`)
* 💧 Auto irrigation system
* 💡 Smart lighting control
* 📊 Realtime monitoring
* 🔄 Mode Auto & Manual
* ⚠️ Risk detection (aman / waspada / bahaya)

---

# 📌 Catatan

* Sistem menggunakan **Realtime Database**
* Pastikan ESP & Flutter menggunakan project Firebase yang sama
* Gunakan mode **manual** untuk testing hardware

---

# 👨‍💻 Tech Stack

* Flutter
* Firebase Realtime Database
* Firebase Functions
* ESP8266 / ESP32
* Arduino C++

---

# 🏁 Status Project

✅ Fuzzy Logic implemented
✅ Realtime IoT working
✅ Manual control working
✅ Dashboard ready

---

🔥 **Siap untuk demo & presentasi**
