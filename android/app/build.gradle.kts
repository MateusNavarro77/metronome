import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mateusnavarro77.metronome"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

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
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.mateusnavarro77.metronome"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        externalNativeBuild {
            cmake {
                arguments("-DANDROID_STL=c++_shared")
            }
        }
    }

    signingConfigs {
        getByName("debug") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
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

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    buildFeatures {
        prefab = true
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

// AAB config
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

            // Find and rename the AAB file
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

dependencies {
    implementation("com.google.oboe:oboe:1.10.0")
}

flutter {
    source = "../.."
}