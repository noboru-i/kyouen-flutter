import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Parse dart-defines from Flutter build
val dartDefines = mutableMapOf<String, String>()
if (project.hasProperty("dart-defines")) {
    val defines = project.property("dart-defines") as String
    defines.split(",").forEach { define ->
        try {
            val decoded = String(Base64.getDecoder().decode(define))
            val pair = decoded.split("=", limit = 2)
            if (pair.size == 2) {
                dartDefines[pair[0]] = pair[1]
            }
        } catch (e: Exception) {
            // Skip invalid entries
        }
    }
}

android {
    namespace = "hm.orz.chaos114.android.tumekyouen.kyouen_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
        }
    }

    defaultConfig {
        applicationId = dartDefines["ANDROID_APPLICATION_ID"]?.takeIf { it.isNotEmpty() }
            ?: "hm.orz.chaos114.android.tumekyouen"

        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Set app name from dart-defines
        resValue("string", "app_name", dartDefines["APP_NAME"] ?: "詰め共円")
    }

    signingConfigs {
        getByName("debug") {
            storeFile = file("cert/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
        create("release") {
            storeFile = file("cert/release.keystore")
            storePassword = System.getenv("STORE_PASSWORD")
            keyAlias = "chaos114"
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
