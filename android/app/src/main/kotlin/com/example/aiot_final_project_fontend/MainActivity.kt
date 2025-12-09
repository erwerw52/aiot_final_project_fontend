package com.example.aiot_final_project_fontend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var duixSdkHandler: DuixSdkHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 初始化 DUIX SDK Handler
        duixSdkHandler = DuixSdkHandler(this)
        duixSdkHandler.registerWith(flutterEngine)
    }
}
