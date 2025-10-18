import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.deep_ocean_v2"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.deep_ocean_v2"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --- load keystore props ---
    val keystoreProps = Properties().apply {
        val propsFile = rootProject.file("android/key.properties")
        if (propsFile.exists()) propsFile.inputStream().use { load(it) }
    }

    signingConfigs {
        create("release") {
            // If you used a different property key, adjust here
            val storeFileName = keystoreProps.getProperty("storeFile") ?: "deepocean.keystore"
            storeFile = file(storeFileName)
            storePassword = keystoreProps.getProperty("storePassword")
            keyAlias = keystoreProps.getProperty("keyAlias")
            keyPassword = keystoreProps.getProperty("keyPassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        // Debug stays as-is
    }
}

flutter {
    source = "../.."
}
