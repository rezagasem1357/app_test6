import 'package:flutter/material.dart';

class Detection {
  final int id;
  final Rect box;
  final double confidence;
  bool isDeleted;

  Detection({
    required this.id,
    required this.box,
    this.confidence = 1.0,
    this.isDeleted = false,
  });

  Detection copyWith({
    int? id,
    Rect? box,
    double? confidence,
    bool? isDeleted,
  }) {
    return Detection(
      id: id ?? this.id,
      box: box ?? this.box,
      confidence: confidence ?? this.confidence,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
