import 'dart:async';
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
  static const int _maxImageSize = 300;
  static const double _markerSize = 150;
  static const double _borderWidth = 10.0;
  static const double _shadowOffset = 2.0;

  /// Create a custom marker with user photo and live indicator
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
      print('Error creating user marker with live indicator: $e');
      return _createFallbackUserMarker(locationData);
    }
  }

  /// Create a standard user marker (for backward compatibility)
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
        borderColor: AppColors.teal,
        cacheKey: cacheKey,
        markerType: 'user',
      );

      return marker;
    } catch (e) {
      print('Error creating user marker: $e');
      return _createFallbackMarker(AppColors.teal);
    }
  }

  /// Create a custom marker with case photo
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
      print('Error creating case marker: $e');
      return _createFallbackMarker(_getStatusColor(status));
    }
  }

  /// Get live indicator color based on freshness
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

  static Future<BitmapDescriptor> _createFallbackUserMarker(
    UserLocationModel locationData,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    const double size = _markerSize;
    const double borderWidth = _borderWidth;
    const double shadowOffset = _shadowOffset;

    final borderColor = _getLiveIndicatorColor(locationData.freshness);

    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size / 2 + shadowOffset, size / 2 + shadowOffset),
      size / 2,
      paint,
    );

    paint.color = borderColor;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Draw inner white circle
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - borderWidth,
      paint,
    );

    // Draw default icon
    paint.color = borderColor;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      (size / 2) - (borderWidth * 2),
      paint,
    );

    // Add live indicator dot
    paint.color = borderColor;
    canvas.drawCircle(
      Offset(size - 15, 15), // Top right corner
      8,
      paint,
    );

    // Add white border around indicator
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(size - 15, 15), 8, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    picture.dispose();
    img.dispose();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  /// Create fallback marker with consistent size
  static Future<BitmapDescriptor> _createFallbackMarker(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    // Draw shadow
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawCircle(
      Offset(_markerSize / 2 + _shadowOffset, _markerSize / 2 + _shadowOffset),
      _markerSize / 2,
      paint,
    );

    // Draw outer border
    paint.color = color;
    canvas.drawCircle(
      Offset(_markerSize / 2, _markerSize / 2),
      _markerSize / 2,
      paint,
    );

    // Draw inner white circle
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(_markerSize / 2, _markerSize / 2),
      _markerSize / 2 - _borderWidth,
      paint,
    );

    // Draw default icon
    paint.color = color;
    canvas.drawCircle(
      Offset(_markerSize / 2, _markerSize / 2),
      (_markerSize / 2) - (_borderWidth * 2),
      paint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(_markerSize.toInt(), _markerSize.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    picture.dispose();
    img.dispose();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  /// Create a photo marker with live indicator
  static Future<BitmapDescriptor> _createPhotoMarkerWithLiveIndicator({
    required String imageUrl,
    required UserLocationModel locationData,
    required String fallbackImagePath,
    required String cacheKey,
  }) async {
    try {
      ui.Image? image = await _loadAndResizeImage(imageUrl, fallbackImagePath);

      if (image == null) {
        print('Failed to load image, using fallback marker');
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
      print('Error in _createPhotoMarkerWithLiveIndicator: $e');
      return _createFallbackUserMarker(locationData);
    }
  }

  /// Create a standard photo marker
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
        print('Failed to load image, using fallback marker');
        return _createFallbackMarker(borderColor);
      }

      final marker = await _drawPhotoMarker(image, borderColor);

      _cache[cacheKey] = marker;
      image.dispose();

      return marker;
    } catch (e) {
      print('Error in _createPhotoMarker: $e');
      return _createFallbackMarker(borderColor);
    }
  }

  /// Load and resize image to exact size for consistency
  static Future<ui.Image?> _loadAndResizeImage(
    String imageUrl,
    String fallbackPath,
  ) async {
    Uint8List? imageBytes;

    try {
      if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
        print('Loading image from: $imageUrl');
        final response = await http
            .get(Uri.parse(imageUrl))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
          print('Network image loaded, size: ${imageBytes.length} bytes');
        }
      }
    } catch (e) {
      print('Failed to load network image: $e');
    }

    if (imageBytes == null) {
      try {
        final ByteData data = await rootBundle.load(fallbackPath);
        imageBytes = data.buffer.asUint8List();
        print('Fallback image loaded, size: ${imageBytes.length} bytes');
      } catch (e) {
        print('Failed to load fallback image: $e');
        return null;
      }
    }

    if (imageBytes == null) return null;

    try {
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(imageBytes, (ui.Image img) {
        completer.complete(img);
      });

      final originalImage = await completer.future;
      final resizedImage = await _resizeImageToSquare(originalImage);
      originalImage.dispose();

      return resizedImage;
    } catch (e) {
      print('Error decoding/resizing image: $e');
      return null;
    }
  }

  /// Resize image to exact square dimensions for consistency
  static Future<ui.Image> _resizeImageToSquare(ui.Image image) async {
    const int targetSize = 200;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(
      0,
      0,
      targetSize.toDouble(),
      targetSize.toDouble(),
    );

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    final picture = recorder.endRecording();
    final resizedImage = await picture.toImage(targetSize, targetSize);
    picture.dispose();

    print('Image resized to consistent ${targetSize}x${targetSize}');
    return resizedImage;
  }

  /// Draw photo marker with live indicator
  static Future<BitmapDescriptor> _drawPhotoMarkerWithLiveIndicator(
    ui.Image image,
    UserLocationModel locationData,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    const double size = _markerSize;
    const double borderWidth = _borderWidth;
    const double shadowOffset = _shadowOffset;

    final borderColor = _getLiveIndicatorColor(locationData.freshness);

    // Draw shadow
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawCircle(
      Offset(size / 2 + shadowOffset, size / 2 + shadowOffset),
      size / 2,
      paint,
    );

    // Draw outer border with live color
    paint.color = borderColor;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Draw inner white circle
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - borderWidth,
      paint,
    );

    // Clip to circle and draw image
    final imageSize = size - (borderWidth * 2) - 4;
    final imageOffset = (size - imageSize) / 2;

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(imageOffset, imageOffset, imageSize, imageSize),
        Radius.circular(imageSize / 2),
      ),
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(imageOffset, imageOffset, imageSize, imageSize),
      Paint(),
    );

    canvas.restore();

    // Add live indicator dot in top-right corner
    paint.color = borderColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size - 20, 20), // Top right corner
      12,
      paint,
    );

    // Add white border around indicator
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(Offset(size - 20, 20), 12, paint);

    // Add inner indicator (different for live vs recent)
    paint.style = PaintingStyle.fill;
    if (locationData.isLive) {
      // Live: solid circle
      paint.color = Colors.white;
      canvas.drawCircle(Offset(size - 20, 20), 6, paint);
    } else {
      // Recent: clock icon
      paint.color = Colors.white;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(size - 20, 20), 5, paint);

      // Clock hands
      paint.style = PaintingStyle.fill;
      canvas.drawLine(Offset(size - 20, 20), Offset(size - 20, 16), paint);
      canvas.drawLine(Offset(size - 20, 20), Offset(size - 17, 20), paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    picture.dispose();
    img.dispose();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  /// Draw standard photo marker
  static Future<BitmapDescriptor> _drawPhotoMarker(
    ui.Image image,
    Color borderColor,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    const double size = _markerSize;
    const double borderWidth = _borderWidth;
    const double shadowOffset = _shadowOffset;

    // Draw shadow
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawCircle(
      Offset(size / 2 + shadowOffset, size / 2 + shadowOffset),
      size / 2,
      paint,
    );

    // Draw outer border
    paint.color = borderColor;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Draw inner white circle
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - borderWidth,
      paint,
    );

    // Clip to circle and draw image
    final imageSize = size - (borderWidth * 2) - 4;
    final imageOffset = (size - imageSize) / 2;

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(imageOffset, imageOffset, imageSize, imageSize),
        Radius.circular(imageSize / 2),
      ),
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(imageOffset, imageOffset, imageSize, imageSize),
      Paint(),
    );

    canvas.restore();

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    picture.dispose();
    img.dispose();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  /// Clear cache to free memory
  static void clearCache() {
    print('Clearing marker cache, size: ${_cache.length}');
    _cache.clear();
  }

  /// Get cache size for debugging
  static int getCacheSize() {
    return _cache.length;
  }

  /// Clear cache when memory is low
  static void onMemoryWarning() {
    print('Memory warning - clearing marker cache');
    clearCache();
  }
}
