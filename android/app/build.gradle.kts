plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.translator_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.translator_app"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true

        manifestPlaceholders["appAuthRedirectScheme"] = "com.example.translator_app"
        manifestPlaceholders["googleRedirectScheme"] = "com.example.translator_app"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("debug") {
            isDebuggable = true
        }
    }

    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}