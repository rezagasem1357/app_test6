import 'dart:io';

import 'package:flutter/material.dart';

import '../services/counting_engine.dart';
import 'result_screen.dart';

class SelectObjectScreen extends StatefulWidget {
  final String imagePath;

  const SelectObjectScreen({super.key, required this.imagePath});

  @override
  State<SelectObjectScreen> createState() => _SelectObjectScreenState();
}

class _SelectObjectScreenState extends State<SelectObjectScreen> {
  Rect? _selection;

  Offset? _startPoint;
  Offset? _currentPoint;

  bool _isCounting = false;

  final CountingEngine _engine = CountingEngine();

  Size? _imageSize;

  Future<void> _loadImageSize() async {
    final imageProvider = FileImage(File(widget.imagePath));

    final stream = imageProvider.resolve(const ImageConfiguration());

    final completer = ImageStreamListener((info, synchronousCall) {
      if (!mounted) return;

      setState(() {
        _imageSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
      });
    });

    stream.addListener(completer);
  }

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  void _startSelection(DragStartDetails details) {
    setState(() {
      _startPoint = details.localPosition;
      _currentPoint = details.localPosition;
      _selection = null;
    });
  }

  void _updateSelection(DragUpdateDetails details) {
    if (_startPoint == null) return;

    setState(() {
      _currentPoint = details.localPosition;
    });
  }

  void _finishSelection(DragEndDetails details) {
    if (_startPoint == null || _currentPoint == null) {
      return;
    }

    final left = _startPoint!.dx < _currentPoint!.dx
        ? _startPoint!.dx
        : _currentPoint!.dx;

    final top = _startPoint!.dy < _currentPoint!.dy
        ? _startPoint!.dy
        : _currentPoint!.dy;

    final right = _startPoint!.dx > _currentPoint!.dx
        ? _startPoint!.dx
        : _currentPoint!.dx;

    final bottom = _startPoint!.dy > _currentPoint!.dy
        ? _startPoint!.dy
        : _currentPoint!.dy;

    final rect = Rect.fromLTRB(left, top, right, bottom);

    if (rect.width < 25 || rect.height < 25) {
      setState(() {
        _selection = null;
        _startPoint = null;
        _currentPoint = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کادر انتخاب‌شده خیلی کوچک است.')),
      );

      return;
    }

    setState(() {
      _selection = rect;
      _startPoint = null;
      _currentPoint = null;
    });
  }

  Future<void> _startCounting() async {
    final selection = _selection;

    if (selection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا دور یک کالا کادر بکشید.')),
      );
      return;
    }

    if (_isCounting) return;

    setState(() {
      _isCounting = true;
    });

    try {
      final detections = await _engine.countObjects(
        image: File(widget.imagePath),
        referenceBox: selection,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imagePath: widget.imagePath,
            selection: selection,
            detections: detections,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطا در شمارش:\n$e')));
    } finally {
      if (mounted) {
        setState(() {
          _isCounting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('انتخاب کالا'),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: GestureDetector(
                    onPanStart: _startSelection,
                    onPanUpdate: _updateSelection,
                    onPanEnd: _finishSelection,

                    child: Stack(
                      children: [
                        Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.contain,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        ),

                        if (_selection != null)
                          Positioned(
                            left: _selection!.left,
                            top: _selection!.top,
                            width: _selection!.width,
                            height: _selection!.height,

                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.greenAccent,
                                  width: 3,
                                ),
                                color: Colors.greenAccent.withValues(
                                  alpha: 0.15,
                                ),
                              ),

                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'نمونه',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        if (_startPoint != null &&
                            _currentPoint != null &&
                            _selection == null)
                          Positioned(
                            left: _startPoint!.dx < _currentPoint!.dx
                                ? _startPoint!.dx
                                : _currentPoint!.dx,

                            top: _startPoint!.dy < _currentPoint!.dy
                                ? _startPoint!.dy
                                : _currentPoint!.dy,

                            width: (_startPoint!.dx - _currentPoint!.dx).abs(),

                            height: (_startPoint!.dy - _currentPoint!.dy).abs(),

                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.yellow,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
            color: Colors.black,

            child: Column(
              children: [
                const Text(
                  'دور یک نمونه از کالای موردنظر کادر بکشید',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: FilledButton.icon(
                    onPressed: _isCounting ? null : _startCounting,

                    icon: _isCounting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),

                    label: Text(
                      _isCounting ? 'در حال شمارش...' : 'شروع شمارش',

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
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
