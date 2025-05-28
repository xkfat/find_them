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
  // ignore: unused_field
  static const int _maxImageSize = 300;
  static const double _markerSize = 160;
  static const double _borderWidth = 10.0;
  static const double _shadowOffset = 2.0;

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
        borderColor: AppColors.teal,
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

    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - borderWidth,
      paint,
    );

    paint.color = borderColor;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      (size / 2) - (borderWidth * 2),
      paint,
    );

    paint.color = borderColor;
    canvas.drawCircle(Offset(size - 15, 15), 8, paint);

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

  static Future<BitmapDescriptor> _createFallbackMarker(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(_markerSize / 2 + _shadowOffset, _markerSize / 2 + _shadowOffset),
      _markerSize / 2,
      paint,
    );

    paint.color = color;
    canvas.drawCircle(
      Offset(_markerSize / 2, _markerSize / 2),
      _markerSize / 2,
      paint,
    );

    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(_markerSize / 2, _markerSize / 2),
      _markerSize / 2 - _borderWidth,
      paint,
    );

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
    Uint8List? imageBytes;

    try {
      if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
        log('Loading image from: $imageUrl');
        final response = await http
            .get(Uri.parse(imageUrl))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
          log('Network image loaded, size: ${imageBytes.length} bytes');
        }
      }
    } catch (e) {
      log('Failed to load network image: $e');
    }

    if (imageBytes == null) {
      try {
        final ByteData data = await rootBundle.load(fallbackPath);
        imageBytes = data.buffer.asUint8List();
        log('Fallback image loaded, size: ${imageBytes.length} bytes');
      } catch (e) {
        log('Failed to load fallback image: $e');
        return null;
      }
    }

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
      log('Error decoding/resizing image: $e');
      return null;
    }
  }

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

    log('Image resized to consistent ${targetSize}x${targetSize}');
    return resizedImage;
  }

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

    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size / 2 + shadowOffset, size / 2 + shadowOffset),
      size / 2,
      paint,
    );

    paint.color = borderColor;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - borderWidth,
      paint,
    );

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

    paint.color = borderColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size - 20, 20), 12, paint);

    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(Offset(size - 20, 20), 12, paint);

    paint.style = PaintingStyle.fill;
    if (locationData.isLive) {
      paint.color = Colors.white;
      canvas.drawCircle(Offset(size - 20, 20), 6, paint);
    } else {
      paint.color = Colors.white;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(size - 20, 20), 5, paint);

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

    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size / 2 + shadowOffset, size / 2 + shadowOffset),
      size / 2,
      paint,
    );

    paint.color = borderColor;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - borderWidth,
      paint,
    );

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
