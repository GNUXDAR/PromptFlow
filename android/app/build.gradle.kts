import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma (en orden de prioridad):
//  1. android/key.properties → keystore de publicación propio (storeFile,
//     storePassword, keyAlias, keyPassword). Recomendado para distribuir.
//  2. android/debug.keystore del proyecto → mismo esquema que Synapse
//     (com.actecnology.*): copiando ese archivo, ambas apps comparten firma.
//  3. Si no hay ninguno, el debug.keystore de este equipo (~/.android).
// Ningún keystore se versiona (ver .gitignore).
val keyProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val projectDebugKeystore = rootProject.file("debug.keystore")

android {
    namespace = "com.actecnology.promptflow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.actecnology.promptflow"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // API 24 (Android 7.0), igual que Synapse: amplía los teléfonos compatibles.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("project") {
            if (keyProperties.isNotEmpty()) {
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            } else if (projectDebugKeystore.exists()) {
                storeFile = projectDebugKeystore
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }
    }

    buildTypes {
        val signing = if (keyProperties.isNotEmpty() || projectDebugKeystore.exists()) {
            signingConfigs.getByName("project")
        } else {
            signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signing
            // Reglas para JNA/Vosk: sin ellas R8 rompe la carga nativa (ver el archivo).
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug { signingConfig = signing }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Reconocimiento de voz offline (incluye libvosk.so para arm64-v8a,
    // armeabi-v7a, x86 y x86_64, y JNA como AAR).
    implementation("com.alphacephei:vosk-android:0.3.75")
}
