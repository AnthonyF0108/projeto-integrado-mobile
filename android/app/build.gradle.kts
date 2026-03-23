plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "br.com.webanthony.projetointegrado"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Aqui é onde estava o erro. Vamos forçar o 17 para bater com o de cima.
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "br.com.webanthony.projetointegrado"

        // Colocando os números direto para não ter erro de referência
        minSdk = flutter.minSdkVersion
        targetSdk = 34 // Versão padrão atual do Android

        // Simplificando o versionCode para o Kotlin
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {

    implementation(platform("com.google.firebase:firebase-bom:34.10.0"))

    implementation("com.google.firebase:firebase-analytics")

    implementation("com.google.android.gms:play-services-auth:21.0.0")
}
