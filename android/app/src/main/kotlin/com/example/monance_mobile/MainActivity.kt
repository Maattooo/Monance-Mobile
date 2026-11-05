package com.example.monance_mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.monance_mobile/device_lifecycle"
    private var methodChannel: MethodChannel? = null
    private var screenOffReceiver: BroadcastReceiver? = null
    private var deviceWasLocked = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "consumeDeviceLock") {
                val wasLocked = deviceWasLocked
                deviceWasLocked = false
                result.success(wasLocked)
            } else {
                result.notImplemented()
            }
        }

        screenOffReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_SCREEN_OFF) {
                    deviceWasLocked = true
                    runOnUiThread {
                        methodChannel?.invokeMethod("onDeviceLocked", null)
                    }
                }
            }
        }

        val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
        registerReceiver(screenOffReceiver, filter)
    }

    override fun onDestroy() {
        super.onDestroy()
        screenOffReceiver?.let {
            unregisterReceiver(it)
            screenOffReceiver = null
        }
    }
}

