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

  // Pin marker dimensions (matching original size)
  static const double _markerWidth =
      160.0; // Width of the pin (matching original _markerSize)
  static const double _markerHeight =
      200.0; // Total height including point (proportional)
  static const double _circleRadius =
      70.0; // Radius of the photo circle (larger)
  static const double _borderWidth =
      10.0; // Border thickness (matching original)
  static const double _pinPointHeight =
      40.0; // Height of the triangle point (proportional)
  static const double _shadowOffset = 2.0; // Shadow offset (same)

  static Future<BitmapDescriptor> createUserMarkerWithLiveIndicator({
    required String imageUrl,
    required UserLocationModel locationData,
    String? fallbackImagePath,
  }) async {
    final String cacheKey =
        'user_live_${locationData.user}_${locationData.freshness}_${imageUrl.hashCode}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final marker = await _createPhotoMarkerWithLiveIndicator(
        imageUrl: imageUrl,
        locationData: locationData,
        fallbackImagePath: fallbackImagePath ?? 'assets/images/profile.png',
        cacheKey: cacheKey,
      );

      return marker;
    } catch (e) {
      log('Error creating user marker with live indicator: $e');
      return _createFallbackUserMarker(locationData);
    }
  }

  static Future<BitmapDescriptor> createUserMarker({
    required String imageUrl,
    String? fallbackImagePath,
  }) async {
    final String cacheKey = 'user_${imageUrl.hashCode}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final marker = await _createPhotoMarker(
        imageUrl: imageUrl,
        fallbackImagePath: fallbackImagePath ?? 'assets/images/profile.png',
        borderColor: AppColors.teal, // Keep Flutter colors
        cacheKey: cacheKey,
        markerType: 'user',
      );

      return marker;
    } catch (e) {
      log('Error creating user marker: $e');
      return _createFallbackMarker(AppColors.teal);
    }
  }

  static Future<BitmapDescriptor> createCaseMarker({
    required String imageUrl,
    required String status,
    String? fallbackImagePath,
  }) async {
    final String cacheKey = 'case_${status}_${imageUrl.hashCode}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      Color borderColor = _getStatusColor(status);

      final marker = await _createPhotoMarker(
        imageUrl: imageUrl,
        fallbackImagePath: fallbackImagePath ?? 'assets/images/profile.png',
        borderColor: borderColor,
        cacheKey: cacheKey,
        markerType: 'case',
      );

      return marker;
    } catch (e) {
      log('Error creating case marker: $e');
      return _createFallbackMarker(_getStatusColor(status));
    }
  }

  static Color _getLiveIndicatorColor(String freshness) {
    switch (freshness) {
      case 'live':
        return Colors.teal;
      case 'recent':
        return Colors.teal;
      default:
        return AppColors.teal;
    }
  }

  // Keep your existing Flutter colors (don't change this)
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

  // Draw the pin shape (circle + triangle point)
  static void _drawPinShape(
    Canvas canvas,
    Paint paint,
    Color borderColor,
    double centerX,
    double centerY,
  ) {
    // Draw shadow for the entire pin
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawCircle(
      Offset(centerX + _shadowOffset, centerY + _shadowOffset),
      _circleRadius + _borderWidth,
      paint,
    );

    // Draw shadow triangle point (larger)
    final shadowTrianglePath =
        Path()
          ..moveTo(
            centerX - 24 + _shadowOffset,
            centerY + _circleRadius + _shadowOffset,
          )
          ..lineTo(
            centerX + _shadowOffset,
            centerY + _circleRadius + _pinPointHeight + _shadowOffset,
          )
          ..lineTo(
            centerX + 24 + _shadowOffset,
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

    // Draw triangle point (pin bottom) - larger
    final trianglePath =
        Path()
          ..moveTo(centerX - 24, centerY + _circleRadius)
          ..lineTo(centerX, centerY + _circleRadius + _pinPointHeight)
          ..lineTo(centerX + 24, centerY + _circleRadius)
          ..close();
    canvas.drawPath(trianglePath, paint);

    // Draw white inner circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(centerX, centerY), _circleRadius, paint);
  }

  static Future<BitmapDescriptor> _createFallbackUserMarker(
    UserLocationModel locationData,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final borderColor = _getLiveIndicatorColor(locationData.freshness);
    final centerX = _markerWidth / 2;
    final centerY =
        _circleRadius + _borderWidth + 10; // Add some top padding (larger)

    // Draw pin shape
    _drawPinShape(canvas, paint, borderColor, centerX, centerY);

    // Draw inner colored circle for fallback
    paint.color = borderColor;
    canvas.drawCircle(
      Offset(centerX, centerY),
      _circleRadius - _borderWidth,
      paint,
    );

    // Add live indicator
    if (locationData.isLive) {
      // White background (larger indicator)
      paint.color = Colors.white;
      canvas.drawCircle(Offset(centerX + 30, centerY - 30), 12, paint);

      // Green live dot (larger)
      paint.color = Colors.green;
      canvas.drawCircle(Offset(centerX + 30, centerY - 30), 10, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      _markerWidth.toInt(),
      _markerHeight.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    picture.dispose();
    img.dispose();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  static Future<BitmapDescriptor> _createFallbackMarker(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final centerX = _markerWidth / 2;
    final centerY =
        _circleRadius + _borderWidth + 10; // Add some top padding (larger)

    // Draw pin shape
    _drawPinShape(canvas, paint, color, centerX, centerY);

    // Draw inner colored circle for fallback
    paint.color = color;
    canvas.drawCircle(
      Offset(centerX, centerY),
      _circleRadius - _borderWidth,
      paint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      _markerWidth.toInt(),
      _markerHeight.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    picture.dispose();
    img.dispose();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  static Future<BitmapDescriptor> _createPhotoMarkerWithLiveIndicator({
    required String imageUrl,
    required UserLocationModel locationData,
    required String fallbackImagePath,
    required String cacheKey,
  }) async {
    try {
      ui.Image? image = await _loadAndResizeImage(imageUrl, fallbackImagePath);

      if (image == null) {
        log('Failed to load image, using fallback marker');
        return _createFallbackUserMarker(locationData);
      }

      final marker = await _drawPhotoMarkerWithLiveIndicator(
        image,
        locationData,
      );

      _cache[cacheKey] = marker;
      image.dispose();

      return marker;
    } catch (e) {
      log('Error in _createPhotoMarkerWithLiveIndicator: $e');
      return _createFallbackUserMarker(locationData);
    }
  }

  static Future<BitmapDescriptor> _createPhotoMarker({
    required String imageUrl,
    required String fallbackImagePath,
    required Color borderColor,
    required String cacheKey,
    required String markerType,
  }) async {
    try {
      ui.Image? image = await _loadAndResizeImage(imageUrl, fallbackImagePath);

      if (image == null) {
        log('Failed to load image, using fallback marker');
        return _createFallbackMarker(borderColor);
      }

      final marker = await _drawPhotoMarker(image, borderColor);

      _cache[cacheKey] = marker;
      image.dispose();

      return marker;
    } catch (e) {
      log('Error in _createPhotoMarker: $e');
      return _createFallbackMarker(borderColor);
    }
  }

  static Future<ui.Image?> _loadAndResizeImage(
    String imageUrl,
    String fallbackPath,
  ) async {
    Uint8List? imageData;

    // Try to load from network first
    try {
      if (imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          imageData = response.bodyBytes;
        }
      }
    } catch (e) {
      log('Failed to load network image: $e');
    }

    // Fallback to asset image
    if (imageData == null) {
      try {
        final assetData = await rootBundle.load(fallbackPath);
        imageData = assetData.buffer.asUint8List();
      } catch (e) {
        log('Failed to load asset image: $e');
        return null;
      }
    }

    if (imageData == null) return null;

    try {
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: (_circleRadius * 2 - _borderWidth * 2).toInt(),
        targetHeight: (_circleRadius * 2 - _borderWidth * 2).toInt(),
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      log('Failed to decode image: $e');
      return null;
    }
  }

  // Draw photo marker with pin shape and live indicator
  static Future<BitmapDescriptor> _drawPhotoMarkerWithLiveIndicator(
    ui.Image image,
    UserLocationModel locationData,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final borderColor = _getLiveIndicatorColor(locationData.freshness);
    final centerX = _markerWidth / 2;
    final centerY =
        _circleRadius + _borderWidth + 10; // Add some top padding (larger)

    // Draw pin shape
    _drawPinShape(canvas, paint, borderColor, centerX, centerY);

    // Clip and draw the circular image
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

    // Add live indicator
    if (locationData.isLive) {
      // White background (larger indicator)
      paint.color = Colors.white;
      canvas.drawCircle(Offset(centerX + 30, centerY - 30), 12, paint);

      // Green live dot (larger)
      paint.color = Colors.green;
      canvas.drawCircle(Offset(centerX + 30, centerY - 30), 10, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      _markerWidth.toInt(),
      _markerHeight.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    picture.dispose();
    img.dispose();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  // Draw photo marker with pin shape
  static Future<BitmapDescriptor> _drawPhotoMarker(
    ui.Image image,
    Color borderColor,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final centerX = _markerWidth / 2;
    final centerY =
        _circleRadius + _borderWidth + 10; // Add some top padding (larger)

    // Draw pin shape
    _drawPinShape(canvas, paint, borderColor, centerX, centerY);

    // Clip and draw the circular image
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

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      _markerWidth.toInt(),
      _markerHeight.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    picture.dispose();
    img.dispose();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  static void clearCache() {
    log('Clearing marker cache, size: ${_cache.length}');
    _cache.clear();
  }

  static int getCacheSize() {
    return _cache.length;
  }

  static void onMemoryWarning() {
    log('Memory warning - clearing marker cache');
    clearCache();
  }
}
