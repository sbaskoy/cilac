import 'package:flutter/services.dart';

class LocationPermissionManager {
  static const _methodChannel =  MethodChannel("com.oryaz.cilac/backgroudservice");

  static Future<bool> getAlwaysLocationPermissin() async {
    bool res = await _methodChannel.invokeMethod("alwaysLocation");
    return res;
  }
}
