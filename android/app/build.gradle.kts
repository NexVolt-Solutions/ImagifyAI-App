import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.imagifyai.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.imagifyai.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            val keyAlias = keystoreProperties["keyAlias"] as? String
            val keyPassword = keystoreProperties["keyPassword"] as? String
            val storeFileProp = keystoreProperties["storeFile"] as? String
            val storePassword = keystoreProperties["storePassword"] as? String
            
            if (keyAlias != null && keyPassword != null && storeFileProp != null && storePassword != null) {
                create("release") {
                    this.keyAlias = keyAlias
                    this.keyPassword = keyPassword
                    storeFile = rootProject.file(storeFileProp)
                    this.storePassword = storePassword
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfigs.findByName("release")?.let {
                signingConfig = it
            }
            // Enable ProGuard/R8 code shrinking and obfuscation
            // Disabled for initial release - can be enabled later after adding Play Core dependency
            isMinifyEnabled = false
            isShrinkResources = false
            // ProGuard rules file
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
