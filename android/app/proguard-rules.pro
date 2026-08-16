# Google ML Kit ProGuard Rules
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }

# Bỏ qua các cảnh báo liên quan đến các ngôn ngữ không sử dụng (Chinese, Japanese, Korean, Devanagari)
# Điều này giúp tránh lỗi "Missing classes" khi R8 cố gắng tối ưu hóa nhưng các thư viện này không được cài đặt.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_chinese.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_devanagari.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_japanese.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_korean.**
