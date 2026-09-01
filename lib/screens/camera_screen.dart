import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;

  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  bool _isInitializing = true;
  bool _isTakingPicture = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeCamera();
  }

  Future<void> _initializeCamera({int? index}) async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('هیچ دوربینی روی دستگاه پیدا نشد.');
      }

      if (index != null) {
        _cameraIndex = index;
      } else {
        final backIndex = _cameras.indexWhere(
          (camera) =>
              camera.lensDirection == CameraLensDirection.back,
        );

        _cameraIndex = backIndex >= 0 ? backIndex : 0;
      }

      await _controller?.dispose();

      final controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      _controller = controller;

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _errorMessage = 'خطا در راه‌اندازی دوربین:\n$e';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(index: _cameraIndex);
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    try {
      setState(() {
        _isTakingPicture = true;
      });

      final XFile file = await controller.takePicture();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CapturedImageScreen(
            imagePath: file.path,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در گرفتن عکس:\n$e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    final nextIndex =
        (_cameraIndex + 1) % _cameras.length;

    await _initializeCamera(index: nextIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('گرفتن عکس'),
        centerTitle: true,

        actions: [
          if (_cameras.length > 1)
            IconButton(
              onPressed:
                  _isInitializing ? null : _switchCamera,
              icon: const Icon(
                Icons.flip_camera_android,
              ),
            ),
        ],
      ),

      body: _buildCameraView(),

      bottomNavigationBar:
          _buildBottomControls(),
    );
  }

  Widget _buildCameraView() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: Text(
          'دوربین آماده نیست.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_isInitializing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 18,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isTakingPicture
                  ? null
                  : _takePicture,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                ),
                child: _isTakingPicture
                    ? const Padding(
                        padding: EdgeInsets.all(18),
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// صفحه نمایش عکس گرفته شده
class CapturedImageScreen extends StatelessWidget {
  final String imagePath;

  const CapturedImageScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('عکس گرفته شده'),
        centerTitle: true,
      ),

      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () {
              // مرحله بعد:
              // انتخاب کالا با کادر
            },
            child: const Text(
              'انتخاب کالا برای شمارش',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}