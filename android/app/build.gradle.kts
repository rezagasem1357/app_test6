
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.apptest4"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.apptest4"

        // Android 7.0 / API 24
        minSdk = 24

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // فعلاً برای تست
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

/*
 * Google MediaPipe Tasks
 *
 * این کتابخانه برای:
 * - Object Detection
 * - Image Embedding
 * - Image Segmentation
 * - سایر قابلیت‌های Vision
 *
 * استفاده می‌شود.
 */
dependencies {
   implementation("com.google.mediapipe:tasks-vision:latest.release"
   )
}

flutter {
    source = "../.."
}
