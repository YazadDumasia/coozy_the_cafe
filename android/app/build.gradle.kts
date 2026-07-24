plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.app.coozy_the_cafe"
    compileSdk = 37
    ndkVersion = "30.0.14904198 rc1"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.app.coozy_the_cafe"
        minSdk = 24
        targetSdk = 37
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
//            isMinifyEnabled = true
//            isShrinkResources = true
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
//            )
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    compileSdkMinor = 0
    buildToolsVersion = "37.0.0"
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.window:window:1.5.1")
    implementation("androidx.window:window-java:1.5.1")
    implementation("androidx.lifecycle:lifecycle-service:2.11.0")
    //keep the desugaring library in the dependencies as you have it.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

//        implementation(platform("com.google.firebase:firebase-bom:34.16.0"))
//        implementation("com.google.firebase:firebase-auth")
//        implementation("com.google.android.gms:play-services-auth:21.6.0")
}

flutter {
    source = "../.."
}
