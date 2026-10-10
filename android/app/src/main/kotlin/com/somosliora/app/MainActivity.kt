package com.somosliora.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.somosliora.app/focus",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasAccess" -> result.success(FocusMode.hasAccess(this))
                "openSettings" -> result.success(FocusMode.openSettings(this))
                "enable" -> result.success(FocusMode.enable(this))
                "disable" -> result.success(FocusMode.disable(this))
                else -> result.notImplemented()
            }
        }
    }
}
