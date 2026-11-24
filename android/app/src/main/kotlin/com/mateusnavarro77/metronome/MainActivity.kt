package com.mateusnavarro77.metronome

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private var notificationsChannel: MethodChannel? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        )
        notificationsChannel = channel

        MetronomeNotificationService.actionListener = { command ->
            mainHandler.post {
                notificationsChannel?.invokeMethod("onNotificationCommand", command)
            }
        }
        MetronomeNotificationService.closeAppHandler = {
            mainHandler.postDelayed({
                finishAndRemoveTask()
            }, 120L)
        }

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                        checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                        PackageManager.PERMISSION_GRANTED
                    ) {
                        requestPermissions(
                            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                            REQUEST_POST_NOTIFICATIONS,
                        )
                    }
                    result.success(null)
                }

                "syncNotification" -> {
                    val bpm = call.argument<Int>("bpm") ?: 120
                    val isPlaying = call.argument<Boolean>("isPlaying") ?: false
                    val intent = Intent(this, MetronomeNotificationService::class.java).apply {
                        action = MetronomeNotificationService.ACTION_UPDATE
                        putExtra(MetronomeNotificationService.EXTRA_BPM, bpm)
                        putExtra(MetronomeNotificationService.EXTRA_IS_PLAYING, isPlaying)
                    }
                    if (isPlaying) {
                        ContextCompat.startForegroundService(this, intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }

                "dismissNotification" -> {
                    val intent = Intent(this, MetronomeNotificationService::class.java).apply {
                        action = MetronomeNotificationService.ACTION_DISMISS
                    }
                    startService(intent)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        MetronomeNotificationService.actionListener = null
        MetronomeNotificationService.closeAppHandler = null
        notificationsChannel?.setMethodCallHandler(null)
        notificationsChannel = null
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL_NAME = "com.mateusnavarro77.metronome/notifications"
        private const val REQUEST_POST_NOTIFICATIONS = 1001
    }
}
