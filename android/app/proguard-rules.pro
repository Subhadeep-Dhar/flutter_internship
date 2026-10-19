# ProGuard / R8 rules for ShopSphere release build

# Suppress Play Store split install warnings from Flutter embedding
-dontwarn com.google.android.play.core.**

# Preserve annotations, signatures, and reflection attributes
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Keep Kotlin runtime, coroutines, and reflection
-keep class kotlin.** { *; }
-keep interface kotlin.** { *; }
-dontwarn kotlin.**
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Keep Pigeon platform channels and shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**
-keep class dev.flutter.pigeon.shared_preferences_android.** { *; }
-dontwarn dev.flutter.pigeon.shared_preferences_android.**
-keep class dev.flutter.pigeon.** { *; }
-dontwarn dev.flutter.pigeon.**

# Keep FlutterSecureStorage classes
-keep class io.flutter.plugins.flutter_secure_storage.** { *; }
-dontwarn io.flutter.plugins.flutter_secure_storage.**

# Standard Flutter plugin keep rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

