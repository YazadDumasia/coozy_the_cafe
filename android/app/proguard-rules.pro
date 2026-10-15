# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Prevent Obfuscation of Flutter Entrypoint & Native methods
-keepclasseswithmembers class * {
    native <methods>;
}

-keepclassmembers class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler {
   <fields>;
   <methods>;
}

-keepclassmembers class * extends io.flutter.plugin.common.BasicMessageChannel$MessageHandler {
   <fields>;
   <methods>;
}

-keepclassmembers class * extends io.flutter.plugin.common.EventChannel$StreamHandler {
   <fields>;
   <methods>;
}

# AndroidX & Multidex
-keep class androidx.multidex.** { *; }
-keep class androidx.window.** { *; }
-keep class androidx.lifecycle.** { *; }

# Drift / SQLite3
-keep class com.simonbingham.** { *; }
-keep class net.sqlcipher.** { *; }
-keep class org.sqlite.** { *; }

# Image Cropper (uCrop)
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Printing / PDF / Bluetooth thermal
-keep class com.baseflow.** { *; }
-keep class net.posprinter.** { *; }

# Mobile Scanner
-keep class com.google.mlkit.** { *; }
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Geolocator & Location
-keep class com.baseflow.geolocator.** { *; }
-keep class com.baseflow.geocoding.** { *; }

# Secure Storage
-keep class androidx.security.crypto.** { *; }

# Serialization / JSON / Models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Firebase Core & Firebase Auth
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.internal.firebase_auth.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class io.flutter.plugins.firebaseauth.** { *; }
-keepattributes *JavascriptInterface*

# Google Sign In & Play Services Auth
-keep class com.google.android.gms.auth.api.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class io.flutter.plugins.googlesignin.** { *; }

# Flutter Webview Plugin (and Android WebView interfaces)
-keep class com.flutter_webview_plugin.** { *; }
-dontwarn com.flutter_webview_plugin.**
-keepclassmembers class * extends android.webkit.WebChromeClient {
   *;
}
-keepclassmembers class * extends android.webkit.WebViewClient {
   *;
}
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep attributes required for debugging stack traces
-keepattributes *Annotation*,EnclosingMethod,Signature,InnerClasses,SourceFile,LineNumberTable
-dontwarn okio.**
-dontwarn javax.annotation.**

# Play Core / SplitInstall (Flutter Deferred Components / PlayStore Split Application)
-dontwarn com.google.android.play.core.**

