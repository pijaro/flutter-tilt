import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:stream_transform/stream_transform.dart';

class Tilt {
  static const placeholderString = 'Making package';

  final Stream<GyroscopeEvent> _gyroscope;
  final Stream<AccelerometerEvent> _accelerometer;
  final Stream<MagnetometerEvent> _magnetometer;

  late final Stream<Rotation> stream;

  Rotation _rotation = const Rotation(0, 0, 0);

  Tilt({
    Stream<GyroscopeEvent>? gyroscope,
    Stream<MagnetometerEvent>? magnetometer,
    Stream<AccelerometerEvent>? accelerometer,
  })  : _gyroscope = gyroscope ?? gyroscopeEvents,
        _accelerometer = accelerometer ?? accelerometerEvents,
        _magnetometer = magnetometer ?? magnetometerEvents {
    stream = _gyroscope
        .combineLatest(_accelerometer, (p0, p1) => [p0, p1])
        .buffer(Stream.periodic(const Duration(milliseconds: 20)))
        .map(
      (listOfPairs) {
        var gyr = GyroscopeEvent(0, 0, 0);
        var acc = AccelerometerEvent(0, 0, 0);
        for (final pair in listOfPairs) {
          gyr += pair[0] as GyroscopeEvent;
          acc += pair[1] as AccelerometerEvent;
        }
        _rotation = _rotation.rotate(gyr / listOfPairs.length, acc / listOfPairs.length);
        return _rotation;
      },
    );
  }
}

class Rotation {
  final double xRadian;
  final double yRadian;
  final double zRadian;

  const Rotation(this.xRadian, this.yRadian, this.zRadian);

  double get xDegrees => xRadian * 180 / pi;
  double get yDegrees => yRadian * 180 / pi;
  double get zDegrees => zRadian * 180 / pi;

  Rotation rotate(GyroscopeEvent event, AccelerometerEvent control) {
    final x = xRadian + event.x / 50;
    final y = yRadian + event.y / 50;

    final xControl = atan2(control.y, control.z);
    final yControl = atan2(control.x, control.z);

    return Rotation(
      // TODO: Make ratios customizable
      x * 0.92 + xControl * 0.08,
      y * 0.92 + yControl * 0.08,
      zRadian + event.z / 50,
    );
  }

  @override
  String toString() => 'Rotation:\nx: $xDegrees\ny: $yDegrees\nz: $zDegrees';
}

extension on GyroscopeEvent {
  GyroscopeEvent operator +(GyroscopeEvent other) {
    return GyroscopeEvent(x + other.x, y + other.y, z + other.z);
  }

  GyroscopeEvent operator /(int divider) {
    return GyroscopeEvent(x / divider, y / divider, z / divider);
  }
}

extension on AccelerometerEvent {
  AccelerometerEvent operator +(AccelerometerEvent other) {
    return AccelerometerEvent(x + other.x, y + other.y, z + other.z);
  }

  AccelerometerEvent operator /(int divider) {
    return AccelerometerEvent(x / divider, y / divider, z / divider);
  }
}
