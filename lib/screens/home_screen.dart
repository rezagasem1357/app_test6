import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_screen.dart';
import 'select_object_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;

  Future<void> _pickImageFromGallery() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null || !mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectObjectScreen(
            imagePath: image.path,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در انتخاب عکس:\n$e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'شمارش هوشمند',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 35),

                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.center_focus_strong,
                    size: 75,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'شمارش هوشمند اجسام',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'از کالاها عکس بگیرید، یک نمونه را انتخاب کنید و تعداد نمونه‌های مشابه را پیدا کنید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 45),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.icon(
                    onPressed: _openCamera,
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 26,
                    ),
                    label: const Text(
                      'گرفتن عکس با دوربین',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton.icon(
                    onPressed: _isPickingImage
                        ? null
                        : _pickImageFromGallery,
                    icon: _isPickingImage
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.photo_library_outlined,
                          ),
                    label: Text(
                      _isPickingImage
                          ? 'در حال انتخاب عکس...'
                          : 'انتخاب عکس از گالری',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.looks_one,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'یک عکس از کالاها بگیرید.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.looks_two,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'یکی از کالاها را با کادر انتخاب کنید.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.looks_3,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'برنامه کالاهای مشابه را شمارش می‌کند.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}