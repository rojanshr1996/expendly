# Flutter ProGuard / R8 Rules

# Keep Flutter core classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.customviews.** { *; }
-keep class io.flutter.provider.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Google Mobile Ads classes
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Keep SQLite & Drift native bindings
-keep class io.simonbinder.sqlite3.** { *; }
-dontwarn io.simonbinder.sqlite3.**

# Keep Local Authentication
-keep class androidx.biometric.** { *; }
