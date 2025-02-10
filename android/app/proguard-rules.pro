# Keep a specific class from being obfuscated
-keep class * { *; }
# Keep Flutter-specific classes from being obfuscated (necessary for Flutter apps)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keepattributes *Annotation*  # Keep annotations, important for some libraries

# Optionally, disable obfuscation and shrinking (uncomment if needed for debugging)
# -dontobfuscate
# -dontshrink
