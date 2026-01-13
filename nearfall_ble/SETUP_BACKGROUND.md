# Panduan Menjalankan Aplikasi di Background

## Fitur yang Sudah Diimplementasikan

### 1. **Wakelock**

Aplikasi sudah menggunakan `wakelock_plus` untuk menjaga layar tetap menyala saat aplikasi berjalan, sehingga koneksi BLE tidak terputus.

- Package: `wakelock_plus: ^1.2.8`
- Fitur ini aktif otomatis saat HomePage dibuka
- Screen akan tetap aktif dan koneksi BLE tetap berjalan

### 2. **UI yang Informatif**

Home screen sekarang menampilkan:

- **Connection Status Card**: Status koneksi (Connected/Disconnected)
- **Statistics Card**: Jumlah data yang diterima dan waktu update terakhir
- **Accelerometer Card**: Data akselerometer (X, Y, Z axis dan magnitude)
- **Gyroscope Card**: Data giroskop (X, Y, Z axis)
- **Altitude Card**: Data ketinggian dari sensor BMP280
- **Raw Data Card**: Data mentah dalam format CSV

### 3. **Fungsi Disconnect**

- Tombol disconnect di AppBar (ikon bluetooth_disabled)
- Konfirmasi dialog sebelum disconnect
- Otomatis membersihkan resource (wakelock, subscriptions)
- Kembali ke halaman Connect setelah disconnect

## Konfigurasi Android untuk Background Service

Untuk menjalankan aplikasi di background dengan sempurna, tambahkan konfigurasi berikut:

### 1. Update `android/app/src/main/AndroidManifest.xml`

Tambahkan permission berikut di dalam tag `<manifest>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Existing permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <!-- For keeping app awake -->
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>

    <!-- Disable battery optimization (optional, for better background performance) -->
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>

    <application>
        <!-- Your existing application code -->
    </application>
</manifest>
```

### 2. Nonaktifkan Battery Optimization (Opsional)

Untuk performa optimal, tambahkan code berikut di `main.dart`:

```dart
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request to ignore battery optimization
  await Permission.ignoreBatteryOptimizations.request();

  runApp(const MyApp());
}
```

### 3. Build dan Test

```bash
# Build aplikasi
flutter build apk --release

# Atau jalankan di debug mode
flutter run -d <device-id>
```

## Tips Menggunakan Aplikasi

1. **Saat Membuka Aplikasi**:

   - Scan untuk device ESP32
   - Connect ke device
   - Layar akan tetap menyala otomatis

2. **Saat Aplikasi Berjalan**:

   - Aplikasi akan terus menerima data BLE
   - Monitoring real-time sensor data
   - Statistik terupdate otomatis

3. **Untuk Disconnect**:

   - Tekan ikon disconnect di AppBar
   - Konfirmasi dialog
   - Aplikasi akan kembali ke halaman scan

4. **Battery Management**:
   - Wakelock akan menjaga koneksi tetap aktif
   - Untuk menghemat baterai, disconnect ketika tidak digunakan
   - Pastikan battery optimization dinonaktifkan untuk aplikasi ini

## Troubleshooting

### Koneksi Terputus Saat Screen Off

- Pastikan wakelock aktif
- Nonaktifkan battery optimization untuk aplikasi
- Pastikan permission WAKE_LOCK sudah ditambahkan

### Data Tidak Terupdate

- Cek koneksi BLE (status card harus menunjukkan "Connected")
- Pastikan ESP32 mengirim data dalam format CSV yang benar
- Format: `ax,ay,az,gx,gy,gz,accMag,altitude`

### Permission Error

- Pastikan semua permission di AndroidManifest.xml sudah ditambahkan
- Request permission saat pertama kali aplikasi dibuka
- Untuk Android 12+, permission BLUETOOTH_SCAN dan BLUETOOTH_CONNECT wajib

## Struktur Data

Data yang dikirim dari ESP32 harus dalam format CSV:

```
ax,ay,az,gx,gy,gz,accMag,altitude
```

Contoh:

```
0.15,-0.08,9.81,0.5,-0.3,0.1,9.82,145.50
```

Dimana:

- `ax, ay, az`: Accelerometer X, Y, Z (m/s²)
- `gx, gy, gz`: Gyroscope X, Y, Z (°/s)
- `accMag`: Acceleration Magnitude (m/s²)
- `altitude`: Ketinggian dari sensor BMP280 (meter)
