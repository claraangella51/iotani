# ESP32 Wiring for IoTani

Panduan ini memakai asumsi rangkaian berikut:

- `ESP32` membaca soil sensor dan LDR
- `Relay module` dipakai sebagai saklar beban
- `Pompa` dan `lampu LED 5V` tidak disuplai langsung dari pin ESP32
- `GPIO 25` mengontrol relay pompa
- `GPIO 26` mengontrol relay lampu

## 1. Power utama

- `Adaptor 5V +` ke `VCC relay module`
- `Adaptor 5V -` ke `GND relay module`
- `ESP32 VIN/5V` bisa diambil dari adaptor 5V jika board dan adaptor stabil
- `ESP32 GND` harus disatukan dengan `GND relay` dan `GND sensor`

## 2. Soil moisture sensor

Untuk sensor analog capacitive:

- `VCC sensor` ke `3V3 ESP32`
- `GND sensor` ke `GND ESP32`
- `AO sensor` ke `GPIO 34`

Catatan:

- Hindari memberi `5V` ke pin analog ESP32
- Jika sensor kamu modul resistive murah, bacaan cenderung cepat korosi dan kurang stabil

## 3. LDR analog

Pakai LDR + resistor tetap sebagai pembagi tegangan.

- Satu kaki `LDR` ke `3V3`
- Kaki LDR lain ke `GPIO 35`
- Dari titik `GPIO 35`, pasang resistor `10k ohm` ke `GND`

Artinya `GPIO 35` membaca titik tengah pembagi tegangan.

## 4. Relay control dari ESP32

Jika modul relay 2 channel:

- `IN1 relay` ke `GPIO 25` untuk pompa
- `IN2 relay` ke `GPIO 26` untuk lampu
- `VCC relay` ke `5V`
- `GND relay` ke `GND`

Mayoritas relay module aktif `LOW`, dan firmware di repo ini sudah diset untuk pola itu.

## 5. Wiring pompa 5V lewat relay

Untuk 1 channel relay pompa:

- `Adaptor 5V +` ke `COM relay pompa`
- `NO relay pompa` ke `+ pompa`
- `- pompa` ke `Adaptor 5V -`

Pakai terminal `NO` supaya pompa default mati saat board baru menyala.

## 6. Wiring lampu LED 5V lewat relay

Jika lampu kamu adalah modul `LED 5V siap pakai`:

- `Adaptor 5V +` ke `COM relay lampu`
- `NO relay lampu` ke `+ lampu`
- `- lampu` ke `Adaptor 5V -`

Jika yang kamu punya adalah `LED 3V` biasa tetapi sumbernya `5V`, jangan langsung sambung:

- `Adaptor 5V +` ke `COM relay lampu`
- `NO relay lampu` ke `resistor 100-220 ohm`
- ujung resistor ke `anoda LED (+)`
- `katoda LED (-)` ke `Adaptor 5V -`

`3.3k ohm` akan membuat LED sangat redup. `10 ohm` terlalu kecil dan berisiko membuat LED kelebihan arus.

## 7. Skema ringkas

```text
ESP32 GPIO25  --------> IN1 relay (pompa)
ESP32 GPIO26  --------> IN2 relay (lampu)
ESP32 GND     --------> GND relay, GND sensor, GND adaptor

Soil sensor AO -------> GPIO34
LDR divider  ---------> GPIO35

Adaptor 5V+  ---------> COM relay pompa
NO relay pompa -------> + pompa
- pompa       --------> Adaptor 5V-

Adaptor 5V+  ---------> COM relay lampu
NO relay lampu -------> lampu 5V+
lampu 5V-     --------> Adaptor 5V-
```

## 8. Catatan aman

- Jangan sambungkan pompa atau lampu 5V langsung ke GPIO ESP32
- Pastikan arus adaptor 5V cukup untuk pompa dan lampu
- Jika relay hanya 1 channel, prioritaskan relay untuk pompa dan pakai transistor/MOSFET untuk lampu
- Bila pompa adalah motor DC kecil, lebih aman tambahkan diode flyback jika tidak sudah ada di modul driver
