package com.mateusnavarro77.metronome

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

class MetronomeNotificationService : Service() {

    private var currentBpm: Int = 120
    private var currentIsPlaying: Boolean = false
    private var isInForeground: Boolean = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        ensureNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_UPDATE -> {
                currentBpm = intent.getIntExtra(EXTRA_BPM, currentBpm)
                currentIsPlaying = intent.getBooleanExtra(EXTRA_IS_PLAYING, currentIsPlaying)
                renderNotification()
            }

            ACTION_DECREASE_BPM -> {
                actionListener?.invoke("decreaseBpm")
            }

            ACTION_INCREASE_BPM -> {
                actionListener?.invoke("increaseBpm")
            }

            ACTION_TOGGLE_PLAY_PAUSE -> {
                actionListener?.invoke(if (currentIsPlaying) "pause" else "play")
            }

            ACTION_CLOSE_APP -> {
                currentIsPlaying = false
                actionListener?.invoke("stop")
                stopAndRemoveNotification()
                closeAppHandler?.invoke()
            }

            ACTION_SWIPED_DISMISS -> {
                currentIsPlaying = false
                isInForeground = false
                actionListener?.invoke("stop")
                stopSelf()
            }

            ACTION_DISMISS -> {
                currentIsPlaying = false
                stopAndRemoveNotification()
            }
        }
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        if (!currentIsPlaying) {
            stopAndRemoveNotification()
        }
        super.onTaskRemoved(rootIntent)
    }

    private fun renderNotification() {
        val notification = buildNotification(currentBpm, currentIsPlaying)
        if (currentIsPlaying) {
            val foregroundType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            } else {
                0
            }
            ServiceCompat.startForeground(this, NOTIFICATION_ID, notification, foregroundType)
            isInForeground = true
        } else {
            if (isInForeground) {
                ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_DETACH)
                isInForeground = false
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(NOTIFICATION_ID, notification)
        }
    }

    private fun stopAndRemoveNotification() {
        isInForeground = false
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
        stopSelf()
    }

    private fun buildNotification(bpm: Int, isPlaying: Boolean): Notification {
        val remoteViews = RemoteViews(packageName, R.layout.notification_metronome).apply {
            setTextViewText(R.id.notif_bpm_value, bpm.toString())
            setImageViewResource(
                R.id.notif_btn_play_pause,
                if (isPlaying) R.drawable.ic_notification_pause else R.drawable.ic_notification_play,
            )
            setOnClickPendingIntent(
                R.id.notif_btn_minus,
                serviceActionPendingIntent(ACTION_DECREASE_BPM, REQUEST_MINUS),
            )
            setOnClickPendingIntent(
                R.id.notif_btn_plus,
                serviceActionPendingIntent(ACTION_INCREASE_BPM, REQUEST_PLUS),
            )
            setOnClickPendingIntent(
                R.id.notif_btn_play_pause,
                serviceActionPendingIntent(ACTION_TOGGLE_PLAY_PAUSE, REQUEST_PLAY_PAUSE),
            )
            setOnClickPendingIntent(
                R.id.notif_btn_close,
                serviceActionPendingIntent(ACTION_CLOSE_APP, REQUEST_CLOSE),
            )
        }

        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentPendingIntent = PendingIntent.getActivity(
            this,
            REQUEST_OPEN_APP,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_metronome)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setContentIntent(contentPendingIntent)
            .setDeleteIntent(serviceActionPendingIntent(ACTION_SWIPED_DISMISS, REQUEST_SWIPE))
            .setOngoing(isPlaying)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
    }

    private fun serviceActionPendingIntent(action: String, requestCode: Int): PendingIntent {
        val intent = Intent(this, MetronomeNotificationService::class.java).apply {
            this.action = action
        }
        return PendingIntent.getService(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            "Metronome",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Metronome background playback controls"
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        manager.createNotificationChannel(channel)
    }

    companion object {
        const val CHANNEL_ID = "com.mateusnavarro77.metronome.channel.custom_playback"
        const val NOTIFICATION_ID = 4041

        const val ACTION_UPDATE = "com.mateusnavarro77.metronome.action.UPDATE"
        const val ACTION_DISMISS = "com.mateusnavarro77.metronome.action.DISMISS"
        const val ACTION_DECREASE_BPM = "com.mateusnavarro77.metronome.action.DECREASE_BPM"
        const val ACTION_INCREASE_BPM = "com.mateusnavarro77.metronome.action.INCREASE_BPM"
        const val ACTION_TOGGLE_PLAY_PAUSE = "com.mateusnavarro77.metronome.action.TOGGLE_PLAY_PAUSE"
        const val ACTION_CLOSE_APP = "com.mateusnavarro77.metronome.action.CLOSE_APP"
        const val ACTION_SWIPED_DISMISS = "com.mateusnavarro77.metronome.action.SWIPED_DISMISS"

        const val EXTRA_BPM = "extra_bpm"
        const val EXTRA_IS_PLAYING = "extra_is_playing"

        private const val REQUEST_OPEN_APP = 100
        private const val REQUEST_MINUS = 101
        private const val REQUEST_PLUS = 102
        private const val REQUEST_PLAY_PAUSE = 103
        private const val REQUEST_CLOSE = 104
        private const val REQUEST_SWIPE = 105

        @Volatile
        var actionListener: ((String) -> Unit)? = null

        @Volatile
        var closeAppHandler: (() -> Unit)? = null
    }
}
