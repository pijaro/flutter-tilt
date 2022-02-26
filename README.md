# tilt

Easy access to the current tilt on `x` and `y` axis for supported devices[^1].

The package uses a simplified [complementary filter](https://ahrs.readthedocs.io/en/latest/filters/complementary.html) to estimate device's current roll and pitch based on gyroscope and accelerometer data.

These two data sources are combined in order to mitigate their unique disadvantages (accelerometer's noise and gyroscope's eventual drift), while combining their strengths (accelerometer's relative stability of measurement and gyroscope's precission). 

That being said, it means that no single `Tilt` value should be taken as an absolute true tilt of the device: each emitted value contains some proportion of error. 

# Usage

`DeviceTilt` provides access to a `Stream<Tilt>` which emitts updates at the given sampling rate.

```dart
StreamBuilder<Tilt>(
  stream: DeviceTilt(
    samplingRateMs: 20,
    initialTilt: const Tilt(0, 0),
    filterGain: 0.1,
  ).stream,
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      return Text(snapshot.data!.toString());
    }
    return const CircularProgressIndicator();
  },
);
```

* `samplingRateMs` determines how often the stream emitts updates. It's recommended to keep this value relatively small (i.e., update frequently), otherwise the complementary filter won't be able to correct the tilt values as accurately.
* `initialTilt` is optionally provided, in case you know the exact tilt of the device when you subscribe to the stream. Even if incorrectly assuming (0, 0) as the initial tilt, the values will correct themselves over time, thanks to accelerometer data.
* `filterGain` determines the proportion of gyroscope and accelerometer data present in the final result. If set to `0`, the final estimate is based solely on accelerometer data, while a value of `1` would mean that only gyroscope data determines the tilt. Neither of these extremes are recommended.

# What about yaw?

Theoretically, yaw of the device could be calculated by complementing gyroscope with magnetometer data. Practically, meaningfully magnetometer would have to include a lot of calibration (to get around device's internal magnetic properties), and even then would not be very reliable, due to Earth's magnetic field being much weaker than magnetic fields surrounding the sensor (such as other electronic devices).

Both Android and iOS SDKs provide readily available information about compass heading. However, it's necessary to obtain location permission to access this data, which seemed out of scope for a simple package that calculates the tilt. If you still need the yaw value, I'd suggest checking out [flutter_compass](https://pub.dev/packages/flutter_compass) package.


[^1] it should work on all iOS and Android devices which have gyroscope and accelerometer sensors.
