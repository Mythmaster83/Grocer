allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Fix for packages without namespace (like isar_flutter_libs)
    afterEvaluate {
        if (project.name == "isar_flutter_libs") {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
            if (android != null && android.namespace.isNullOrEmpty()) {
                // Set namespace from AndroidManifest or use default
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestContent = manifestFile.readText()
                    val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestContent)
                    if (packageMatch != null) {
                        android.namespace = packageMatch.groupValues[1]
                    } else {
                        android.namespace = "dev.isar.isar_flutter_libs"
                    }
                } else {
                    android.namespace = "dev.isar.isar_flutter_libs"
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
