allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // flutter_stripe's stripe_android module pulls in
    // com.stripe:stripe-android-issuing-push-provisioning as a compileOnly
    // dependency (for the optional "add card to Google Pay" issuing feature,
    // which this app does not use). That artifact in turn depends on
    // com.google.android.gms:play-services-tapandpay, a private Google SDK
    // not published on any public Maven repo, which breaks
    // :stripe_android:lintVitalAnalyzeRelease during release builds.
    // Excluding it here prevents Gradle from ever trying to resolve it,
    // for every subproject/configuration (compile, lint, etc.). Payment
    // Sheet / Apple Pay / Google Pay checkout are unaffected since they
    // don't touch push-provisioning code paths.
    configurations.all {
        exclude(group = "com.google.android.gms", module = "play-services-tapandpay")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
