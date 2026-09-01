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

        // Android 7.0+
        minSdk = 24

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // برای تست و Codemagic
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
 * MediaPipe Vision Tasks
 *
 * شامل:
 * - Object Detection
 * - Image processing
 * - AI Vision
 *
 * نسخه ثابت برای جلوگیری از
 * مشکل dependency و TFLite conflict
 */
dependencies {
    implementation(
        "com.google.mediapipe:tasks-vision:0.10.14"
    )
}


flutter {
    source = "../.."
}
