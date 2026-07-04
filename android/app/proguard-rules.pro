# Keep the ML Kit text recognition classes we use (Latin script).
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Suppress R8 "missing class" errors for optional/unused transitive references:
# - ML Kit's non-Latin recognizers (Chinese/Japanese/Korean/Devanagari) — not bundled.
# - Huawei HMS variants, Cronet, Conscrypt, BouncyCastle — pulled in transitively,
#   never used by this offline app.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.huawei.**
-dontwarn com.android.org.conscrypt.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn org.chromium.**
