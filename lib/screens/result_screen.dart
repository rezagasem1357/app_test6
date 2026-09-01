
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/detection.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final Rect selection;
  final List<Detection> detections;

  const ResultScreen({
    
    super.key,
    required this.imagePath,
    required this.selection,
    required this.detections,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late List<Detection> _detections;

  int? _selectedId;

  @override
  void initState() {
    super.initState();

    _detections = widget.detections
        .map((item) => item.copyWith())
        .toList();
  }

  List<Detection> get _activeDetections {
    return _detections
        .where((item) => !item.isDeleted)
        .toList();
  }

  int get _activeCount {
    return _activeDetections.length;
  }

  void _selectDetection(Detection detection) {
    setState(() {
      if (_selectedId == detection.id) {
        _selectedId = null;
      } else {
        _selectedId = detection.id;
      }
    });
  }

  void _deleteSelected() {
    final id = _selectedId;

    if (id == null) return;

    setState(() {
      final index = _detections.indexWhere(
        (item) => item.id == id,
      );

      if (index != -1) {
        _detections[index] =
            _detections[index].copyWith(
          isDeleted: true,
        );
      }

      _selectedId = null;
    });
  }

  void _restoreLastDeleted() {
    for (int i = _detections.length - 1; i >= 0; i--) {
      if (_detections[i].isDeleted) {
        setState(() {
          _detections[i] =
              _detections[i].copyWith(
            isDeleted: false,
          );
        });
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'مورد حذف‌شده‌ای برای بازگردانی وجود ندارد.',
        ),
      ),
    );
  }

  void _confirm() {
    Navigator.pop(
      context,
      _activeCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'نتیجه شمارش',
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                return Stack(
                  children: [
                    Center(
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
                    ),

                    ..._activeDetections
                        .asMap()
                        .entries
                        .map(
                      (entry) {
                        final index =
                            entry.key;

                        final detection =
                            entry.value;

                        final isSelected =
                            _selectedId ==
                                detection.id;

                        return Positioned(
                          left: detection.box.left,
                          top: detection.box.top,
                          width: detection.box.width,
                          height: detection.box.height,

                          child: GestureDetector(
                            behavior:
                                HitTestBehavior.opaque,

                            onTap: () {
                              _selectDetection(
                                detection,
                              );
                            },

                            child: AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 150,
                              ),

                              decoration:
                                  BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors
                                          .greenAccent,
                                  width: isSelected
                                      ? 4
                                      : 2,
                                ),

                                color: isSelected
                                    ? Colors.red
                                        .withValues(
                                        alpha: 0.20,
                                      )
                                    : Colors
                                        .greenAccent
                                        .withValues(
                                        alpha: 0.08,
                                      ),
                              ),

                              child: Align(
                                alignment:
                                    Alignment.topLeft,

                                child: Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: isSelected
                                        ? Colors.red
                                        : Colors.green,

                                    borderRadius:
                                        const BorderRadius
                                            .only(
                                      bottomRight:
                                          Radius.circular(
                                        6,
                                      ),
                                    ),
                                  ),

                                  child: Text(
                                    '${index + 1}',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              20,
            ),
            color: Colors.black,

            child: Column(
              children: [
                const Text(
                  'تعداد کالاها',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                Text(
                  '$_activeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (_selectedId != null) ...[
                  const SizedBox(height: 6),

                  Text(
                    'کالای شماره $_selectedId انتخاب شده است',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: FilledButton.icon(
                      style:
                          FilledButton.styleFrom(
                        backgroundColor:
                            Colors.red,
                      ),

                      onPressed:
                          _deleteSelected,

                      icon: const Icon(
                        Icons.delete_outline,
                      ),

                      label: Text(
                        'حذف کالای شماره $_selectedId',
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            _restoreLastDeleted,

                        icon: const Icon(
                          Icons.undo,
                        ),

                        label:
                            const Text(
                          'بازگردانی',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: FilledButton.icon(
                    onPressed: _confirm,

                    icon: const Icon(
                      Icons.check,
                    ),

                    label: const Text(
                      'تأیید شمارش',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
