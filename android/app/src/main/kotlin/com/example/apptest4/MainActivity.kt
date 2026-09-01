package com.example.apptest4

import android.graphics.BitmapFactory
import android.graphics.RectF
import android.os.Bundle

import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.objectdetector.ObjectDetector

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "smart_counter/ai"
        private const val MODEL_NAME = "efficientdet_lite0.tflite"
    }

    private var objectDetector: ObjectDetector? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initializeObjectDetector()
    }

    private fun initializeObjectDetector() {
        try {
            val baseOptions =
                ObjectDetector.ObjectDetectorOptions.builder()
                    .setBaseOptions(
                        com.google.mediapipe.tasks.core.BaseOptions.builder()
                            .setModelAssetPath(MODEL_NAME)
                            .build()
                    )
                    .setRunningMode(RunningMode.IMAGE)
                    .setScoreThreshold(0.30f)
                    .setMaxResults(100)
                    .build()

            objectDetector =
                ObjectDetector.createFromOptions(
                    this,
                    baseOptions
                )

        } catch (e: Exception) {
            objectDetector = null
        }
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "detectObjects" -> {

                    try {

                        val imageBytes =
                            call.argument<ByteArray>("image")

                        val selectionLeft =
                            call.argument<Double>("left") ?: 0.0

                        val selectionTop =
                            call.argument<Double>("top") ?: 0.0

                        val selectionRight =
                            call.argument<Double>("right") ?: 0.0

                        val selectionBottom =
                            call.argument<Double>("bottom") ?: 0.0

                        if (imageBytes == null) {
                            result.error(
                                "IMAGE_ERROR",
                                "تصویر دریافت نشد.",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        val detector = objectDetector

                        if (detector == null) {
                            result.error(
                                "MODEL_ERROR",
                                "مدل هوش مصنوعی بارگذاری نشد.",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        val bitmap =
                            BitmapFactory.decodeByteArray(
                                imageBytes,
                                0,
                                imageBytes.size
                            )

                        if (bitmap == null) {
                            result.error(
                                "IMAGE_ERROR",
                                "خواندن تصویر امکان‌پذیر نیست.",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        val image =
                            BitmapImageBuilder(bitmap).build()

                        val detectionResult =
                            detector.detect(image)

                        val detections =
                            detectionResult.detections()

                        /*
                         * اول تلاش می‌کنیم تشخیصی را پیدا کنیم
                         * که داخل کادر انتخابی کاربر قرار گرفته.
                         */

                        val referenceRect =
                            RectF(
                                selectionLeft.toFloat(),
                                selectionTop.toFloat(),
                                selectionRight.toFloat(),
                                selectionBottom.toFloat()
                            )

                        var referenceCategoryIndex: Int? = null

                        for (detection in detections) {

                            val box =
                                detection.boundingBox()

                            val centerX =
                                box.centerX()

                            val centerY =
                                box.centerY()

                            if (
                                referenceRect.contains(
                                    centerX,
                                    centerY
                                )
                            ) {

                                val categories =
                                    detection.categories()

                                if (categories.isNotEmpty()) {
                                    referenceCategoryIndex =
                                        categories[0].index()
                                }

                                break
                            }
                        }

                        val output =
                            ArrayList<HashMap<String, Any>>()

                        for (detection in detections) {

                            val categories =
                                detection.categories()

                            if (categories.isEmpty()) {
                                continue
                            }

                            val category =
                                categories[0]

                            /*
                             * اگر دسته کالای انتخاب‌شده
                             * مشخص شده باشد، فقط همان کلاس
                             * را نگه می‌داریم.
                             */

                            if (
                                referenceCategoryIndex != null &&
                                category.index() !=
                                referenceCategoryIndex
                            ) {
                                continue
                            }

                            val box =
                                detection.boundingBox()

                            val confidence =
                                category.score()

                            val item =
                                hashMapOf<String, Any>(
                                    "left" to box.left.toDouble(),
                                    "top" to box.top.toDouble(),
                                    "right" to box.right.toDouble(),
                                    "bottom" to box.bottom.toDouble(),
                                    "confidence" to confidence.toDouble()
                                )

                            output.add(item)
                        }

                        /*
                         * اگر مدل هیچ موردی پیدا نکرد،
                         * خود کادر انتخابی را برمی‌گردانیم.
                         */

                        if (output.isEmpty()) {

                            output.add(
                                hashMapOf(
                                    "left" to selectionLeft,
                                    "top" to selectionTop,
                                    "right" to selectionRight,
                                    "bottom" to selectionBottom,
                                    "confidence" to 1.0
                                )
                            )
                        }

                        result.success(output)

                        bitmap.recycle()

                    } catch (e: Exception) {

                        result.error(
                            "AI_ERROR",
                            e.message
                                ?: "خطا در پردازش هوش مصنوعی",
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {

        objectDetector?.close()
        objectDetector = null

        super.onDestroy()
    }
}