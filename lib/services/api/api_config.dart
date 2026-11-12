import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Centralized API Configuration
///
/// For physical Android devices, change [customHostIp] to your laptop's Wi-Fi IPv4 address.
///
/// Current Laptop Wi-Fi IP: 192.168.0.106
/// Port: 3000
class ApiConfig {
  /// Default Wi-Fi IP of your development laptop.
  /// Update this value whenever your laptop connects to a different Wi-Fi network.
  static String customHostIp = '192.168.0.106';

  /// Port on which the Node.js backend runs
  static const int port = 3000;

  /// Returns the appropriate base URL based on runtime platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }

    try {
      if (Platform.isAndroid) {
        // If testing on a physical phone, return laptop Wi-Fi IP
        // To use Android Emulator instead, change this to: return 'http://10.0.2.2:$port/api';
        return 'http://$customHostIp:$port/api';
      } else if (Platform.isIOS) {
        return 'http://$customHostIp:$port/api';
      } else {
        // Windows / macOS / Linux desktop
        return 'http://127.0.0.1:$port/api';
      }
    } catch (_) {
      return 'http://$customHostIp:$port/api';
    }
  }

  /// Convenience URL for Android Emulator specifically
  static String get emulatorBaseUrl => 'http://10.0.2.2:$port/api';

  /// Convenience URL for Physical Phone specifically
  static String get physicalDeviceBaseUrl => 'http://$customHostIp:$port/api';

  /// Health check endpoint URL
  static String get healthUrl => '$baseUrl/health';

  /// Request timeout in seconds
  static const Duration timeout = Duration(seconds: 10);
}
