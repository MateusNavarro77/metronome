import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mateusnavarro77.metronome"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Metronome Dev")
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "Metronome")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.mateusnavarro77.metronome"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }

    buildFeatures {
        resValues = true
    }

    applicationVariants.all {
        val variant = this
        val appName = "metronome"
        val versionName = variant.versionName
        val buildType = variant.buildType.name
        val flavorName = variant.flavorName

        variant.outputs.forEach { output ->
            if (output is com.android.build.gradle.internal.api.BaseVariantOutputImpl) {
                val abi = output.getFilter(com.android.build.OutputFile.ABI)
                val abiSuffix = if (abi != null) "_${abi}" else ""
                output.outputFileName = "${appName}_${flavorName}_v${versionName}_${buildType}${abiSuffix}.apk"
            }
        }
    }
}

// AAB rename config
tasks.whenTaskAdded {
    if (name.startsWith("bundle")) {
        doLast {
            val taskName = name.lowercase()
            val buildType = when {
                taskName.contains("release") -> "release"
                taskName.contains("debug") -> "debug"
                taskName.contains("profile") -> "profile"
                else -> "unknown"
            }
            val flavorName = when {
                taskName.contains("dev") -> "dev"
                taskName.contains("prod") -> "prod"
                else -> ""
            }
            val appName = "metronome"
            val versionName = flutter.versionName

            val flavorBuildType = if (flavorName.isNotEmpty()) {
                "${flavorName}${buildType.replaceFirstChar { it.uppercase() }}"
            } else {
                buildType
            }

            val bundleDir = project.layout.buildDirectory.dir("outputs/bundle/${flavorBuildType}").get().asFile
            if (bundleDir.exists()) {
                bundleDir.listFiles()?.forEach { file ->
                    if (file.name.endsWith(".aab")) {
                        val flavorSuffix = if (flavorName.isNotEmpty()) "_${flavorName}" else ""
                        val newPath = "${appName}${flavorSuffix}_v${versionName}_${buildType}.aab"
                        val newFile = File(bundleDir, newPath)
                        file.renameTo(newFile)
                    }
                }
            }
        }
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
