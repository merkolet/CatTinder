pluginManagement {
    // Всегда используем симлинк вместо пути с кириллицей для совместимости с Gradle
    val flutterSdkPath = "/Users/sergey/flutter"
    
    // Обновляем local.properties, чтобы использовать симлинк
    val localPropertiesFile = file("local.properties")
    if (localPropertiesFile.exists()) {
        val properties = java.util.Properties()
        localPropertiesFile.bufferedReader(java.nio.charset.StandardCharsets.UTF_8).use { reader ->
            properties.load(reader)
        }
        properties.setProperty("flutter.sdk", flutterSdkPath)
        localPropertiesFile.bufferedWriter(java.nio.charset.StandardCharsets.UTF_8).use { writer ->
            properties.store(writer, null)
        }
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
