plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Ensure this is applied in the app-level build.gradle
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fluttertest"  // Set the namespace/package name for your app
    compileSdk = flutter.compileSdkVersion  // Fetching SDK version from Flutter
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Java 17 compatibility
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()  // Set Kotlin to use Java 17
    }

    defaultConfig {
        applicationId = "com.example.fluttertest"  // Your app's unique ID
        minSdk = flutter.minSdkVersion  // Set the minimum SDK version
        targetSdk = flutter.targetSdkVersion  // Set the target SDK version
        versionCode = flutter.versionCode  // Incremental version code
        versionName = flutter.versionName  // Your app's version name
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")  // Set up signing config (for debugging)
        }
    }
}

flutter {
    source = "../.."  // Path to Flutter source directory
}
