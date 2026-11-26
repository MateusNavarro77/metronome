# Keep line numbers and source file names for deobfuscating stack traces with mapping.txt
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep app entry points & foreground service
-keep class com.mateusnavarro77.metronome.MainActivity { *; }
-keep class com.mateusnavarro77.metronome.MetronomeNotificationService { *; }

# Keep native/JNI methods across plugins (e.g., flutter_soloud, sqflite)
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}
