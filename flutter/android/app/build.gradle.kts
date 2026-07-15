import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

val releaseProperties = Properties()
val releasePropertiesFile = rootProject.file("release.properties")
if (releasePropertiesFile.exists()) {
    FileInputStream(releasePropertiesFile).use(releaseProperties::load)
}

val isReleaseTask = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }
val configuredApplicationId = releaseProperties.getProperty("applicationId")
val configuredAdMobAppId = releaseProperties.getProperty("adMobAppId")

if (isReleaseTask) {
    require(!configuredApplicationId.isNullOrBlank()) { "Define applicationId in android/release.properties for release." }
    require(!configuredAdMobAppId.isNullOrBlank()) { "Define adMobAppId in android/release.properties for release." }
    require(keystorePropertiesFile.exists()) { "Create android/key.properties from key.properties.example for release signing." }
}

android {
    namespace = configuredApplicationId ?: "com.focuzlab.tirasuerte"
    compileSdk = flutter.compileSdkVersion
    // Lock NDK to version required by plugins
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = configuredApplicationId ?: "com.focuzlab.tirasuerte"
        manifestPlaceholders["adMobAppId"] = configuredAdMobAppId ?: "ca-app-pub-3940256099942544~3347511713"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.create("release") {
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    storeFile = file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                }
            }
        }
    }
}

flutter {
    source = "../.."
}
