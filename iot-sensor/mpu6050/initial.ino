#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

Adafruit_MPU6050 mpu;
bool mpuOK = false;

bool checkMPU() {
  Wire.beginTransmission(0x68);
  return Wire.endTransmission() == 0;
}

void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10);   // 🔴 WAJIB ESP32

  Serial.println("\nESP32-C3 MPU6050 Test");

  Wire.begin(3, 4); // SDA, SCL
  delay(100);

  if (checkMPU()) {
    if (mpu.begin()) {
      Serial.println("MPU6050 connected");
      mpuOK = true;

      mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
      mpu.setGyroRange(MPU6050_RANGE_500_DEG);
      mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
    } else {
      Serial.println("MPU6050 detected but init failed");
    }
  } else {
    Serial.println("MPU6050 NOT detected");
  }
}

void loop() {
  if (!mpuOK) {
    Serial.println("MPU not ready, retrying...");
    if (checkMPU() && mpu.begin()) {
      Serial.println("MPU6050 reconnected!");
      mpuOK = true;
    }
    delay(1000);
    return;
  }

  sensors_event_t a, g, temp;
  if (!mpu.getEvent(&a, &g, &temp)) {
    Serial.println("MPU read error");
    mpuOK = false;
    delay(500);
    return;
  }

  Serial.print("Accel X: "); Serial.print(a.acceleration.x);
  Serial.print(" Y: "); Serial.print(a.acceleration.y);
  Serial.print(" Z: "); Serial.println(a.acceleration.z);

  delay(500);
}
