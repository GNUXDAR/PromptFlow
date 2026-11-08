# Vosk usa JNA: la librería nativa accede por reflexión/JNI a campos y métodos
# de Java (p. ej. com.sun.jna.Pointer.peer). Si R8 los elimina u ofusca, la
# app se cierra al cargar Vosk con:
#   UnsatisfiedLinkError: Can't obtain peer field ID for class com.sun.jna.Pointer
-keep class com.sun.jna.** { *; }
-keepclassmembers class * extends com.sun.jna.** { public *; }
-keep class org.vosk.** { *; }
-dontwarn java.awt.**
-dontwarn com.sun.jna.**
