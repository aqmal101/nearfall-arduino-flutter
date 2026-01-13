// TODO Implement this library.
class GaitData {
  final double ax, ay, az;
  final double gx, gy, gz;
  final double accMag;
  final double altitude;

  GaitData({
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.accMag,
    required this.altitude,
  });

  factory GaitData.fromCsv(String csv) {
    final v = csv.split(',');
    return GaitData(
      ax: double.parse(v[0]),
      ay: double.parse(v[1]),
      az: double.parse(v[2]),
      gx: double.parse(v[3]),
      gy: double.parse(v[4]),
      gz: double.parse(v[5]),
      accMag: double.parse(v[6]),
      altitude: double.parse(v[7]),
    );
  }
}
