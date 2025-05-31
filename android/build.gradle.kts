buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")  // Актуальная версия
        classpath("com.google.gms:google-services:4.3.15")  // Для Firebase
        // Добавьте другие classpath зависимости при необходимости
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Можно добавить другие репозитории при необходимости
    }
}

// Настройка кастомного пути для build directory (опционально)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")  // Важно для мультимодульных проектов
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}