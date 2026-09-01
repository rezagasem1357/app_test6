import 'dart:io';

import 'package:flutter/services.dart';

import '../models/detection.dart';

class CountingEngine {
  static const MethodChannel _channel = MethodChannel('smart_counter/ai');

  bool _disposed = false;

  Future<List<Detection>> countObjects({
    required File image,
    required Rect referenceBox,
  }) async {
    if (_disposed) {
      throw StateError('CountingEngine has already been disposed.');
    }

    if (!await image.exists()) {
      throw Exception('فایل تصویر پیدا نشد.');
    }

    final bytes = await image.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception('تصویر خالی است.');
    }

    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'detectObjects',
        <String, dynamic>{
          'image': bytes,
          'left': referenceBox.left,
          'top': referenceBox.top,
          'right': referenceBox.right,
          'bottom': referenceBox.bottom,
        },
      );

      if (result == null || result.isEmpty) {
        return _fallbackReference(referenceBox);
      }

      final detections = <Detection>[];

      for (var i = 0; i < result.length; i++) {
        final item = Map<String, dynamic>.from(result[i]);

        final left = (item['left'] as num?)?.toDouble() ?? 0;

        final top = (item['top'] as num?)?.toDouble() ?? 0;

        final right = (item['right'] as num?)?.toDouble() ?? 0;

        final bottom = (item['bottom'] as num?)?.toDouble() ?? 0;

        final confidence = (item['confidence'] as num?)?.toDouble() ?? 0;

        if (right <= left || bottom <= top) {
          continue;
        }

        detections.add(
          Detection(
            id: detections.length + 1,
            box: Rect.fromLTRB(left, top, right, bottom),
            confidence: confidence,
          ),
        );
      }

      if (detections.isEmpty) {
        return _fallbackReference(referenceBox);
      }

      return detections;
    } on MissingPluginException {
      return _fallbackReference(referenceBox);
    } on PlatformException catch (e) {
      throw Exception(
        'خطا در موتور هوش مصنوعی: '
        '${e.message ?? e.code}',
      );
    }
  }

  List<Detection> _fallbackReference(Rect referenceBox) {
    return [Detection(id: 1, box: referenceBox, confidence: 1.0)];
  }

  void dispose() {
    _disposed = true;
  }
}
