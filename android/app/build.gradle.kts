import com.android.build.api.dsl.ApplicationExtension
import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
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

// Load secrets (AdMob, etc.) - use key.properties or create android/secrets.properties
val secretsFile = rootProject.file("secrets.properties")
val secretsProperties = Properties()
if (secretsFile.exists()) {
    secretsProperties.load(FileInputStream(secretsFile))
}
val admobAppId = (keystoreProperties["ADMOB_APP_ID"] ?: secretsProperties["ADMOB_APP_ID"])
    ?.toString()
    ?: "ca-app-pub-8279839772210876~1156823788"

android {
    namespace = "com.imagifyai.app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"


    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.imagifyai.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["ADMOB_APP_ID"] = admobAppId
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
            signingConfigs.findByName("release")?.let { signingConfig = it }
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

// Fail release builds if Play-style signing is missing; do not run this during debug configuration.
afterEvaluate {
    tasks.matching { task ->
        when (task.name) {
            "bundleRelease", "assembleRelease", "packageRelease" -> true
            else -> false
        }
    }.configureEach {
        doFirst {
            // Task scope: use project.extensions — `extensions` here is the task's, not the app's.
            val appExt = project.extensions.getByType(ApplicationExtension::class.java)
            if (appExt.signingConfigs.findByName("release") == null) {
                throw GradleException(
                    "Release signing is not configured. Google Play requires a signed App Bundle.\n" +
                        "1. Copy android/key.properties.template to android/key.properties\n" +
                        "2. Place your keystore (e.g. android/upload-keystore.jks) and set storePassword, keyPassword, keyAlias, storeFile\n" +
                        "3. Run: flutter build appbundle --release\n" +
                        "See PLAY_STORE_RELEASE_GUIDE.md (section \"All uploaded bundles must be signed\")."
                )
            }
        }
    }
}
