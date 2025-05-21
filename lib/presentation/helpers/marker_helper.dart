import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';

enum MarkerType {
  missing,
  found,
  investigating,
  sharing,
}

class MarkerHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> getMarkerIcon(
    MarkerType type,
    String? imageUrl,
  ) async {
    final String cacheKey = '$type-${imageUrl ?? 'default'}';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
    
    switch (type) {
      case MarkerType.missing:
        icon = BitmapDescriptor.defaultMarkerWithHue(
          _getHueFromColor(AppColors.missingRed)
        );
        break;
      case MarkerType.found:
        icon = BitmapDescriptor.defaultMarkerWithHue(
          _getHueFromColor(AppColors.foundGreen)
        );
        break;
      case MarkerType.investigating:
        icon = BitmapDescriptor.defaultMarkerWithHue(
          _getHueFromColor(AppColors.investigatingYellow)
        );
        break;
      case MarkerType.sharing:
        icon = BitmapDescriptor.defaultMarkerWithHue(
          _getHueFromColor(AppColors.teal)
        );
        break;
    }
    
    _cache[cacheKey] = icon;
    return icon;
  }
  
  static double _getHueFromColor(Color color) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    return hsvColor.hue;
  }
}

extension MarkerTypeExtension on String {
  MarkerType toMarkerType() {
    switch (toLowerCase()) {
      case 'missing':
        return MarkerType.missing;
      case 'found':
        return MarkerType.found;
      case 'investigating':
        return MarkerType.investigating;
      case 'sharing':
        return MarkerType.sharing;
      default:
        return MarkerType.missing; 
    }
  }
}