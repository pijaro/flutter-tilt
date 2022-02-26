
import 'dart:async';

import 'package:flutter/services.dart';

class Tilt {
  static const MethodChannel _channel = MethodChannel('tilt');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
