import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:stream_transform/stream_transform.dart';

class DeviceTilt {
  /// How often to receive updates. Defaults to 20 milliseconds
  final int samplingRateMs;

  /// The device's tilt when the [DeviceTilt] class is initialized. Defaults to Tilt(0, 0).
  /// In practice, it's rare that the device will be perfectly horizontal when the measurements start.
  /// Even if the [intialTilt] is incorrect, the error will be fixed over time by the complementary filter.
  /// Exactly when the [Tilt] will be correct depends on [samplingRateMs] and [filterGain]
  final Tilt initialTilt;

  /// A value between 0 and 1 that determines how much of gyroscope and accelerometer data
  /// is added to final [Tilt]. If [filterGain] is 1, [Tilt] will be based entirely of gyroscope data,
  /// while a value of 0 means that [Tilt] is estimated based on accelerometer data only
  final double filterGain;

  /// Emits current [Tilt] every [samplingRateMs] milliseconds.
  late final Stream<Tilt> stream;

  late Tilt _tilt;

  DeviceTilt({
    this.samplingRateMs = 20,
    this.initialTilt = const Tilt(0, 0),
    this.filterGain = 0.1,
    Stream<GyroscopeEvent>? gyroscope,
    Stream<AccelerometerEvent>? accelerometer,
  }) : assert(
          filterGain >= 0 && filterGain <= 1,
          'filterGain must be a valu between 0 and 1, current value is $filterGain',
        ) {
    _tilt = initialTilt;
    stream = (gyroscope ?? gyroscopeEvents)
        .combineLatest(
            (accelerometer ?? accelerometerEvents), (p0, p1) => [p0, p1])
        .buffer(Stream.periodic(Duration(milliseconds: samplingRateMs)))
        .map(
      (listOfPairs) {
        final length = listOfPairs.length;

        // average gyroscope and accelerometer events in the given buffer
        var g = GyroscopeEvent(0, 0, 0);
        var a = AccelerometerEvent(0, 0, 0);
        for (var i = 0; i < length; i++) {
          g += listOfPairs[i][0] as GyroscopeEvent;
          a += listOfPairs[i][1] as AccelerometerEvent;
        }
        g = g / length;
        a = a / length;

        // tilt from gyroscope
        final x = _tilt.xRadian + g.x / (1000 / samplingRateMs);
        final y = _tilt.yRadian + g.y / (1000 / samplingRateMs);

        // tilt from accelerometer
        final roll = atan2(a.y, a.z);
        final pitch = atan2(-a.x, a.z);

        // complemetary filtered tilt
        _tilt = Tilt(
          x * (1 - filterGain) + roll * filterGain,
          y * (1 - filterGain) + pitch * filterGain,
        );
        return _tilt;
      },
    );
  }
}

/// Describes device's position on x and y axis.
class Tilt {
  /// Describes the rotation of the device's longer side
  /// 0 == parallel to the ground
  /// pi/2 == device standing upright, bottom side facing the ground
  /// -pi/2 == device standing upside-down, top side facing the ground
  /// pi and -pi == device's screen facing down
  final double xRadian;

  /// Describes the rotation of the device's shorter side
  /// 0 == parallel to the ground
  /// pi/2 == right side of the device facing the ground, left side up
  /// -pi/2 == left side of the device facing the ground, right side up
  /// pi and -pi == device's screen facing down, shorter sides parallel to the ground
  final double yRadian;

  const Tilt(this.xRadian, this.yRadian);

  /// Describes the rotation of the device's longer side
  /// 0 == parallel to the ground
  /// 90 == device standing upright, bottom side facing the ground
  /// -90 == device standing upside-down, top side facing the ground
  /// 180 and -180 == device's screen facing down
  double get xDegrees => xRadian * 180 / pi;

  /// Describes the rotation of the device's shorter side
  /// 0 == parallel to the ground
  /// 90 == right side of the device facing the ground, left side up
  /// -90 == left side of the device facing the ground, right side up
  /// 180 and -180 == device's screen facing down, shorter sides parallel to the ground
  double get yDegrees => yRadian * 180 / pi;

  @override
  String toString() => 'Tilt:\nx: $xDegrees\ny: $yDegrees';
}

// helper methods for calculating average GyroscopeEvent
extension on GyroscopeEvent {
  GyroscopeEvent operator +(GyroscopeEvent other) {
    return GyroscopeEvent(x + other.x, y + other.y, z + other.z);
  }

  GyroscopeEvent operator /(int divider) {
    return GyroscopeEvent(x / divider, y / divider, z / divider);
  }
}

// helper methods for calculating average AccelerometerEvent
extension on AccelerometerEvent {
  AccelerometerEvent operator +(AccelerometerEvent other) {
    return AccelerometerEvent(x + other.x, y + other.y, z + other.z);
  }

  AccelerometerEvent operator /(int divider) {
    return AccelerometerEvent(x / divider, y / divider, z / divider);
  }
}
