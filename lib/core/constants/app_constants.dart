import 'package:flutter/foundation.dart';

class AppConstants {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb
        ? 'https://konsulify.arkveramc.com/api/v1'
        : 'http://10.0.2.2:3000/api/v1',
  );
}
