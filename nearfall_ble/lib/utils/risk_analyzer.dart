import '../models/gait_data.dart';

enum FallRisk { low, medium, high }

enum BodyPosture { stable, tilted, unstable }

class RiskAnalyzer {
  static FallRisk analyzeRisk(GaitData d) {
    if (d.accMag > 3.0 || d.altitude > 0.4) {
      return FallRisk.high;
    } else if (d.accMag > 2.0) {
      return FallRisk.medium;
    }
    return FallRisk.low;
  }

  static BodyPosture analyzePosture(GaitData d) {
    if (d.az < 7.0 || d.az > 11.5) {
      return BodyPosture.unstable;
    } else if (d.ay.abs() > 3.0) {
      return BodyPosture.tilted;
    }
    return BodyPosture.stable;
  }
}
