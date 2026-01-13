#include <Wire.h>
#include <Adafruit_BMP280.h>

#define SDA_PIN 3
#define SCL_PIN 4

Adafruit_BMP280 bmp;

void setup() {
  Serial.begin(115200);
  delay(1000);

  Wire.begin(SDA_PIN, SCL_PIN);

  if (!bmp.begin(0x76)) {
    Serial.println("BMP280 init gagal");
    return;
  }

  Serial.println("BMP280 OK");
}

void loop() {
  Serial.print("Temp: ");
  Serial.print(bmp.readTemperature());
  Serial.println(" C");

  Serial.print("Pressure: ");
  Serial.print(bmp.readPressure() / 100);
  Serial.println(" hPa");

  Serial.println("------");
  delay(2000);
}
