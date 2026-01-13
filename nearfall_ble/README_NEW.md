# Nearfall BLE - Fall Risk Monitoring

Aplikasi Flutter untuk monitoring risiko jatuh menggunakan sensor MPU6050 dan BMP280 yang terhubung dengan ESP32 via Bluetooth Low Energy (BLE).

## ✨ Fitur Utama

### 1. **Background Running**

- ✅ Menggunakan `wakelock_plus` untuk menjaga aplikasi tetap aktif
- ✅ Screen tetap menyala saat monitoring
- ✅ Koneksi BLE tidak terputus saat aplikasi aktif
- ✅ Battery optimization dapat dinonaktifkan untuk performa optimal

### 2. **UI Informatif**

Home screen menampilkan real-time monitoring:

- **Connection Status**: Status koneksi (Connected/Disconnected) dengan indikator warna
- **Statistics**:
  - Jumlah data packet yang diterima
  - Waktu update terakhir
- **Accelerometer Data**:
  - X, Y, Z axis (m/s²)
  - Acceleration magnitude
- **Gyroscope Data**:
  - X, Y, Z axis (°/s)
- **Altitude**: Ketinggian dari sensor BMP280 (meter)
- **Raw Data**: Data mentah dalam format CSV untuk debugging

### 3. **Disconnect Function**

- ✅ Tombol disconnect di AppBar
- ✅ Konfirmasi dialog sebelum disconnect
- ✅ Automatic resource cleanup
- ✅ Return to connect screen

## 🔧 Teknologi yang Digunakan

- **Flutter SDK**: ^3.8.1
- **BLE Library**: `flutter_reactive_ble: ^5.4.0`
- **Permissions**: `permission_handler: ^12.0.1`
- **Wakelock**: `wakelock_plus: ^1.2.8`

## 📱 Screenshots

```
[Connect Screen]    →    [Home Screen dengan Data Real-time]
   - Scan BLE              - Connection Status
   - Device List           - Sensor Data Cards
   - Connect Button        - Statistics
                           - Disconnect Button
```

## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK (3.8.1 atau lebih baru)
- Android device dengan Bluetooth LE support
- ESP32 dengan sensor MPU6050 dan BMP280

### Installation Steps

1. **Clone repository**

```bash
cd nearfall_ble
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Konfigurasi ESP32**

   - Upload kode Arduino dari folder `iot-sensor/mpu6050+bmp280/`
   - Pastikan device name: `ESP32-FallRisk`
   - UUID sudah sesuai di `lib/core/ble_constants.dart`

4. **Build & Run**

```bash
# Debug mode
flutter run -d <device-id>

# Release mode
flutter build apk --release
```

## 📋 Permissions (Android)

Aplikasi memerlukan permission berikut:

- ✅ `BLUETOOTH` & `BLUETOOTH_ADMIN`
- ✅ `BLUETOOTH_SCAN` & `BLUETOOTH_CONNECT` (Android 12+)
- ✅ `ACCESS_FINE_LOCATION` & `ACCESS_COARSE_LOCATION`
- ✅ `WAKE_LOCK` (untuk background running)
- ✅ `FOREGROUND_SERVICE`
- ✅ `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (opsional)

Semua permission sudah dikonfigurasi di `android/app/src/main/AndroidManifest.xml`

## 📊 Format Data

Data yang dikirim dari ESP32 dalam format CSV:

```
ax,ay,az,gx,gy,gz,accMag,altitude
```

**Contoh:**

```
0.15,-0.08,9.81,0.5,-0.3,0.1,9.82,145.50
```

Dimana:

- `ax, ay, az`: Accelerometer X, Y, Z (m/s²)
- `gx, gy, gz`: Gyroscope X, Y, Z (°/s)
- `accMag`: Acceleration Magnitude (m/s²)
- `altitude`: Ketinggian (meter)

## 🎯 Cara Menggunakan

1. **Launch App**
   - Buka aplikasi
   - Izinkan semua permissions yang diminta
2. **Scan & Connect**
   - Tap tombol scan (floating action button)
   - Pilih device "ESP32-FallRisk" dari list
   - Tunggu hingga connected
3. **Monitoring**
   - Data sensor akan muncul real-time
   - Monitor statistik dan grafik sensor
   - Aplikasi akan tetap running dengan wakelock aktif
4. **Disconnect**
   - Tap ikon disconnect di AppBar
   - Konfirmasi disconnect
   - Aplikasi kembali ke connect screen

## 🔍 Troubleshooting

### Koneksi terputus saat screen off

- Pastikan battery optimization dinonaktifkan
- Wakelock akan menjaga screen tetap menyala

### Permission error

- Pastikan semua permission sudah diberikan
- Untuk Android 12+, BLUETOOTH_SCAN dan BLUETOOTH_CONNECT wajib

### Data tidak terupdate

- Cek format data dari ESP32 (harus CSV)
- Pastikan characteristic UUID sesuai
- Monitor raw data di bagian bawah home screen

### ESP32 tidak terdeteksi

- Pastikan Bluetooth device aktif
- ESP32 harus broadcast dengan nama "ESP32-FallRisk"
- Cek jarak device (max ~10 meter)

## 📝 Development Notes

### Struktur Folder

```
lib/
├── core/
│   └── ble_constants.dart          # BLE UUID constants
├── models/
│   └── gait_data.dart              # Data model
├── screens/
│   ├── connect_screen.dart         # BLE scan & connect
│   └── home_screen.dart            # Data monitoring
├── services/
│   └── ble_service.dart            # BLE service (optional)
└── main.dart                       # Entry point

iot-sensor/
├── mpu6050/                        # MPU6050 test code
├── bmp280/                         # BMP280 test code
└── mpu6050+bmp280/                 # Combined sensor code
    └── initial.ino
```

### BLE Constants

Edit di `lib/core/ble_constants.dart`:

```dart
const String DEVICE_NAME = "ESP32-FallRisk";
const String SERVICE_UUID = "12345678-1234-1234-1234-1234567890ab";
const String CHARACTERISTIC_UUID = "abcd1234-5678-1234-5678-abcdef123456";
```

## 📚 Documentation

- [Setup Background Service](SETUP_BACKGROUND.md) - Panduan lengkap background running
- [Flutter Reactive BLE](https://pub.dev/packages/flutter_reactive_ble)
- [Wakelock Plus](https://pub.dev/packages/wakelock_plus)

## 🤝 Contributing

1. Fork the project
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is for educational purposes (University Final Task).

## 👥 Authors

- Final Task Project - Nearfall Arduino Flutter

## 🙏 Acknowledgments

- Flutter Team
- flutter_reactive_ble package contributors
- ESP32 Arduino Core
- MPU6050 & BMP280 library authors
