import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomMarkerHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> createUserMarker({
    required String imageUrl,
    String? fallbackImagePath,
  }) async {
    const String cacheKey = 'user_marker_teal';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final marker = BitmapDescriptor.defaultMarkerWithHue(
      _getHueFromColor(AppColors.teal),
    );

    _cache[cacheKey] = marker;
    return marker;
  }

  static Future<BitmapDescriptor> createCaseMarker({
    required String imageUrl,
    required String status,
    String? fallbackImagePath,
  }) async {
    final String cacheKey = 'case_$status';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    double hue;
    switch (status.toLowerCase()) {
      case 'missing':
        hue = BitmapDescriptor.hueRed;
        break;
      case 'under_investigation':
      case 'investigating':
        hue = BitmapDescriptor.hueYellow;
        break;
      case 'found':
        hue = BitmapDescriptor.hueGreen;
        break;
      default:
        hue = BitmapDescriptor.hueRed;
    }

    final marker = BitmapDescriptor.defaultMarkerWithHue(hue);
    _cache[cacheKey] = marker;
    return marker;
  }

  static double _getHueFromColor(Color color) {
    final HSVColor hsvColor = HSVColor.fromColor(color);
    return hsvColor.hue;
  }

  static void clearCache() {
    _cache.clear();
  }
}

class SimpleMarkerHelper {
  static BitmapDescriptor getCaseMarkerIcon(String status) {
    switch (status.toLowerCase()) {
      case 'missing':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'under_investigation':
      case 'investigating':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      case 'found':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  static BitmapDescriptor getUserMarkerIcon() {
    return BitmapDescriptor.defaultMarkerWithHue(195.0); 
  }
}
