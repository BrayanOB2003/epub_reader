package com.somosliora.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val openedEpubs = OpenedEpubRelay()

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
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            openedEpubChannel,
        ).setStreamHandler(openedEpubs)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (savedInstanceState == null) {
            OpenedEpubCapture.capture(this, intent, openedEpubs)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        OpenedEpubCapture.capture(this, intent, openedEpubs)
    }
}
