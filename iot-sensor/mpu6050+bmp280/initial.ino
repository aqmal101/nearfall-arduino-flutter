#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_BMP280.h>
#include <Adafruit_Sensor.h>

#define SDA_PIN 3
#define SCL_PIN 4

#define MPU_ADDR 0x68
#define BMP_ADDR 0x76

Adafruit_MPU6050 mpu;
Adafruit_BMP280 bmp;

bool mpuOK = false;
bool bmpOK = false;

// ================= I2C CHECK =================
bool checkI2C(uint8_t addr) {
  Wire.beginTransmission(addr);
  return Wire.endTransmission() == 0;
}

// ================= INIT MPU =================
void initMPU() {
  if (checkI2C(MPU_ADDR) && mpu.begin()) {
    Serial.println("MPU6050 connected");
    mpuOK = true;

    mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
    mpu.setGyroRange(MPU6050_RANGE_500_DEG);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  } else {
    Serial.println("MPU6050 NOT ready");
    mpuOK = false;
  }
}

// ================= INIT BMP =================
void initBMP() {
  if (checkI2C(BMP_ADDR) && bmp.begin(BMP_ADDR)) {
    Serial.println("BMP280 connected");
    bmpOK = true;
  } else {
    Serial.println("BMP280 NOT ready");
    bmpOK = false;
  }
}

void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10);   // WAJIB ESP32-C3

  Serial.println("\nESP32-C3 MPU6050 + BMP280");

  Wire.begin(SDA_PIN, SCL_PIN);
  delay(300);

  initMPU();
  initBMP();
}

void loop() {
  // ===== MPU6050 =====
  if (!mpuOK) {
    Serial.println("Retry MPU6050...");
    initMPU();
  } else {
    sensors_event_t a, g, temp;
    if (mpu.getEvent(&a, &g, &temp)) {
      Serial.print("[MPU] Accel X: ");
      Serial.print(a.acceleration.x);
      Serial.print(" Y: ");
      Serial.print(a.acceleration.y);
      Serial.print(" Z: ");
      Serial.println(a.acceleration.z);
    } else {
      Serial.println("MPU read error");
      mpuOK = false;
    }
  }

  // ===== BMP280 =====
  if (!bmpOK) {
    Serial.println("Retry BMP280...");
    initBMP();
  } else {
    float temperature = bmp.readTemperature();
    float pressure = bmp.readPressure();

    if (isnan(temperature) || isnan(pressure)) {
      Serial.println("BMP read error");
      bmpOK = false;
    } else {
      Serial.print("[BMP] Temp: ");
      Serial.print(temperature);
      Serial.print(" °C | Pressure: ");
      Serial.print(pressure / 100);
      Serial.println(" hPa");
    }
  }

  Serial.println("---------------------------");
  delay(2000);
}
