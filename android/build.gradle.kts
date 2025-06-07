allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 为所有子项目设置统一的Java版本
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            extensions.configure<com.android.build.gradle.BaseExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
                
                // 为缺少namespace的子项目添加默认namespace
                if (!hasProperty("namespace") || 
                    extensions.findByType<com.android.build.gradle.LibraryExtension>()?.namespace.isNullOrEmpty() == true ||
                    extensions.findByType<com.android.build.gradle.AppExtension>()?.namespace.isNullOrEmpty() == true) {
                    
                    val defaultNamespace = when (project.name) {
                        "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
                        "flutter_inappwebview_android" -> "com.pichillilorenzo.flutter_inappwebview_android"
                        "shared_preferences_android" -> "io.flutter.plugins.sharedpreferences"
                        "permission_handler_android" -> "com.baseflow.permissionhandler"
                        "receive_sharing_intent" -> "com.kasem.receive_sharing_intent"
                        "path_provider_android" -> "io.flutter.plugins.pathprovider"
                        "url_launcher_android" -> "io.flutter.plugins.urllauncher"
                        else -> when {
                            project.name.startsWith("flutter_") -> "com.example.${project.name}"
                            project.name.endsWith("_android") -> "com.example.${project.name}"
                            else -> "com.example.${project.name}"
                        }
                    }
                    
                    when (this) {
                        is com.android.build.gradle.LibraryExtension -> {
                            namespace = defaultNamespace
                        }
                        is com.android.build.gradle.AppExtension -> {
                            if (namespace.isNullOrEmpty()) {
                                namespace = defaultNamespace
                            }
                        }
                    }
                }
            }
        }
        
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
            kotlinOptions.jvmTarget = "17"
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
