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

        variant.outputs.forEach { output ->
            if (output is com.android.build.gradle.internal.api.BaseVariantOutputImpl) {
                val abi = output.getFilter(com.android.build.OutputFile.ABI)
                val abiSuffix = if (abi != null) "_${abi}" else ""
                output.outputFileName = "${appName}_v${versionName}_${buildType}${abiSuffix}.apk"
            }
        }
    }
}

// AAB config
tasks.whenTaskAdded {
    if (name.startsWith("bundle")) {
        doLast {
            val buildType = when {
                name.contains("Release") -> "release"
                name.contains("Debug") -> "debug"
                name.contains("Profile") -> "profile"
                else -> "unknown"
            }
            val appName = "metronome"
            val versionName = flutter.versionName

            // Find and rename the AAB file
            val bundleDir = project.layout.buildDirectory.dir("outputs/bundle/${buildType}").get().asFile
            if (bundleDir.exists()) {
                bundleDir.listFiles()?.forEach { file ->
                    if (file.name.endsWith(".aab")) {
                        val newPath = "${appName}_v${versionName}_${buildType}.aab"
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