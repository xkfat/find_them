import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/data/models/user_location.dart';
import 'package:http/http.dart' as http;

class CustomMarkerHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  // Your requested marker dimensions
  static const double _markerWidth = 160.0;
  static const double _markerHeight = 200.0;
  static const double _circleRadius = 70.0;
  static const double _borderWidth = 10.0;
  static const double _pinPointHeight = 40.0;
  static const double _shadowOffset = 2.0;

  // Simplified cache management
  static const int _maxCacheSize = 50;
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheTimeout = Duration(hours: 1);

  // Network timeout
  static const Duration _networkTimeout = Duration(seconds: 3);

  static Future<BitmapDescriptor> createUserMarkerWithLiveIndicator({
    required String imageUrl,
    required UserLocationModel locationData,
    String? fallbackImagePath,
  }) async {
    final String cacheKey =
        'user_live_${locationData.user}_${locationData.isLive}_${imageUrl.hashCode}';

    // Check cache first
    if (_cache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      // Load image with timeout
      final imageData = await _loadImageWithTimeout(
        imageUrl,
        fallbackImagePath ?? 'assets/images/profile.png',
      );

      if (imageData == null) {
        log('Failed to load image, using default marker');
        return BitmapDescriptor.defaultMarkerWithHue(
          locationData.isLive ? 120.0 : 195.0,
        );
      }

      // Create marker
      final marker = await _createUserMarkerWithLiveIndicator(
        imageData,
        locationData,
      );

      // Cache result
      _cache[cacheKey] = marker;
      _cacheTimestamps[cacheKey] = DateTime.now();
      _cleanCacheIfNeeded();

      return marker;
    } catch (e) {
      log('Error creating user marker with live indicator: $e');
      return BitmapDescriptor.defaultMarkerWithHue(
        locationData.isLive ? 120.0 : 195.0,
      );
    }
  }

  static Future<BitmapDescriptor> createUserMarker({
    required String imageUrl,
    String? fallbackImagePath,
  }) async {
    final String cacheKey = 'user_${imageUrl.hashCode}';

    // Check cache first
    if (_cache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      // Load image with timeout
      final imageData = await _loadImageWithTimeout(
        imageUrl,
        fallbackImagePath ?? 'assets/images/profile.png',
      );

      if (imageData == null) {
        log('Failed to load image, using default marker');
        return BitmapDescriptor.defaultMarkerWithHue(195.0);
      }

      // Create marker
      final marker = await _createUserMarker(imageData, AppColors.teal);

      // Cache result
      _cache[cacheKey] = marker;
      _cacheTimestamps[cacheKey] = DateTime.now();
      _cleanCacheIfNeeded();

      return marker;
    } catch (e) {
      log('Error creating user marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(195.0);
    }
  }

  static Future<BitmapDescriptor> createCaseMarker({
    required String imageUrl,
    required String status,
    String? fallbackImagePath,
  }) async {
    final String cacheKey = 'case_${status}_${imageUrl.hashCode}';

    // Check cache first
    if (_cache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      // Load image with timeout
      final imageData = await _loadImageWithTimeout(
        imageUrl,
        fallbackImagePath ?? 'assets/images/profile.png',
      );

      if (imageData == null) {
        log('Failed to load image, using default marker');
        return _getDefaultCaseMarker(status);
      }

      // Create marker
      final borderColor = _getStatusColor(status);
      final marker = await _createCaseMarker(imageData, borderColor);

      // Cache result
      _cache[cacheKey] = marker;
      _cacheTimestamps[cacheKey] = DateTime.now();
      _cleanCacheIfNeeded();

      return marker;
    } catch (e) {
      log('Error creating case marker: $e');
      return _getDefaultCaseMarker(status);
    }
  }

  // Simplified image loading with timeout
  static Future<Uint8List?> _loadImageWithTimeout(
    String imageUrl,
    String fallbackPath,
  ) async {
    Uint8List? imageData;

    // Try network image first if URL is not empty
    if (imageUrl.isNotEmpty) {
      try {
        final response = await http
            .get(Uri.parse(imageUrl))
            .timeout(_networkTimeout);
        if (response.statusCode == 200) {
          imageData = response.bodyBytes;
        }
      } catch (e) {
        log('Network image failed: $e');
      }
    }

    // Fallback to asset
    if (imageData == null) {
      try {
        final assetData = await rootBundle.load(fallbackPath);
        imageData = assetData.buffer.asUint8List();
      } catch (e) {
        log('Asset image failed: $e');
      }
    }

    return imageData;
  }

  // Create user marker with live indicator
  static Future<BitmapDescriptor> _createUserMarkerWithLiveIndicator(
    Uint8List imageData,
    UserLocationModel locationData,
  ) async {
    try {
      // Decode image
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: (_circleRadius * 2).toInt(),
        targetHeight: (_circleRadius * 2).toInt(),
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Create canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      final centerX = _markerWidth / 2;
      final centerY = _circleRadius + _borderWidth + 20;

      // Draw pin shape
      _drawPinShape(canvas, paint, AppColors.teal, centerX, centerY);

      // Draw circular image
      _drawCircularImage(canvas, image, centerX, centerY);

      // Draw live indicator if needed
      if (locationData.isLive) {
        _drawLiveIndicator(canvas, paint, centerX, centerY);
      }

      // Convert to bitmap
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        _markerWidth.toInt(),
        _markerHeight.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Clean up
      picture.dispose();
      img.dispose();
      image.dispose();

      return BitmapDescriptor.fromBytes(pngBytes);
    } catch (e) {
      log('Error creating user marker with live indicator: $e');
      return BitmapDescriptor.defaultMarkerWithHue(195.0);
    }
  }

  // Create regular user marker
  static Future<BitmapDescriptor> _createUserMarker(
    Uint8List imageData,
    Color borderColor,
  ) async {
    try {
      // Decode image
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: (_circleRadius * 2).toInt(),
        targetHeight: (_circleRadius * 2).toInt(),
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Create canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      final centerX = _markerWidth / 2;
      final centerY = _circleRadius + _borderWidth + 20;

      // Draw pin shape
      _drawPinShape(canvas, paint, borderColor, centerX, centerY);

      // Draw circular image
      _drawCircularImage(canvas, image, centerX, centerY);

      // Convert to bitmap
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        _markerWidth.toInt(),
        _markerHeight.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Clean up
      picture.dispose();
      img.dispose();
      image.dispose();

      return BitmapDescriptor.fromBytes(pngBytes);
    } catch (e) {
      log('Error creating user marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(195.0);
    }
  }

  // Create case marker
  static Future<BitmapDescriptor> _createCaseMarker(
    Uint8List imageData,
    Color borderColor,
  ) async {
    try {
      // Decode image
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: (_circleRadius * 2).toInt(),
        targetHeight: (_circleRadius * 2).toInt(),
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Create canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      final centerX = _markerWidth / 2;
      final centerY = _circleRadius + _borderWidth + 20;

      // Draw pin shape
      _drawPinShape(canvas, paint, borderColor, centerX, centerY);

      // Draw circular image
      _drawCircularImage(canvas, image, centerX, centerY);

      // Convert to bitmap
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        _markerWidth.toInt(),
        _markerHeight.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Clean up
      picture.dispose();
      img.dispose();
      image.dispose();

      return BitmapDescriptor.fromBytes(pngBytes);
    } catch (e) {
      log('Error creating case marker: $e');
      return _getDefaultCaseMarker('missing');
    }
  }

  // Draw pin shape (teardrop)
  static void _drawPinShape(
    Canvas canvas,
    Paint paint,
    Color borderColor,
    double centerX,
    double centerY,
  ) {
    // Draw shadow
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawCircle(
      Offset(centerX + _shadowOffset, centerY + _shadowOffset),
      _circleRadius + _borderWidth,
      paint,
    );

    // Draw shadow triangle
    final shadowTrianglePath =
        Path()
          ..moveTo(
            centerX - 20 + _shadowOffset,
            centerY + _circleRadius + _shadowOffset,
          )
          ..lineTo(
            centerX + _shadowOffset,
            centerY + _circleRadius + _pinPointHeight + _shadowOffset,
          )
          ..lineTo(
            centerX + 20 + _shadowOffset,
            centerY + _circleRadius + _shadowOffset,
          )
          ..close();
    canvas.drawPath(shadowTrianglePath, paint);

    // Draw colored border circle
    paint.color = borderColor;
    canvas.drawCircle(
      Offset(centerX, centerY),
      _circleRadius + _borderWidth,
      paint,
    );

    // Draw triangle point
    final trianglePath =
        Path()
          ..moveTo(centerX - 20, centerY + _circleRadius)
          ..lineTo(centerX, centerY + _circleRadius + _pinPointHeight)
          ..lineTo(centerX + 20, centerY + _circleRadius)
          ..close();
    canvas.drawPath(trianglePath, paint);

    // Draw white inner circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(centerX, centerY), _circleRadius, paint);
  }

  // Draw circular image
  static void _drawCircularImage(
    Canvas canvas,
    ui.Image image,
    double centerX,
    double centerY,
  ) {
    final imageRadius = _circleRadius - (_borderWidth / 2);

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: imageRadius * 2,
          height: imageRadius * 2,
        ),
        Radius.circular(imageRadius),
      ),
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: imageRadius * 2,
        height: imageRadius * 2,
      ),
      Paint(),
    );

    canvas.restore();
  }

  // Draw live indicator
  static void _drawLiveIndicator(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
  ) {
    final indicatorX = centerX + _circleRadius - 15;
    final indicatorY = centerY - _circleRadius + 15;

    // White background
    paint.color = Colors.white;
    canvas.drawCircle(Offset(indicatorX, indicatorY), 12, paint);

    // Green indicator
    paint.color = Colors.green;
    canvas.drawCircle(Offset(indicatorX, indicatorY), 10, paint);
  }

  // Helper methods
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'missing':
        return AppColors.missingRed;
      case 'under_investigation':
      case 'investigating':
        return AppColors.investigatingYellow;
      case 'found':
        return AppColors.foundGreen;
      default:
        return AppColors.missingRed;
    }
  }

  static BitmapDescriptor _getDefaultCaseMarker(String status) {
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

  // Cache management
  static bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheTimeout;
  }

  static void _cleanCacheIfNeeded() {
    if (_cache.length > _maxCacheSize) {
      final now = DateTime.now();
      final expiredKeys = <String>[];

      _cacheTimestamps.forEach((key, timestamp) {
        if (now.difference(timestamp) > _cacheTimeout ||
            expiredKeys.length < (_cache.length - _maxCacheSize)) {
          expiredKeys.add(key);
        }
      });

      for (final key in expiredKeys) {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }

      log('Cleaned cache: removed ${expiredKeys.length} entries');
    }
  }

  // Public utility methods
  static void clearCache() {
    log('Clearing marker cache, size: ${_cache.length}');
    _cache.clear();
    _cacheTimestamps.clear();
  }

  static int getCacheSize() {
    return _cache.length;
  }

  static void onMemoryWarning() {
    log('Memory warning - cleaning cache');
    _cleanCacheIfNeeded();
  }
}
