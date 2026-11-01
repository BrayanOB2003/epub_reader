package com.somosliora.app

import android.app.Activity
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings

/// Silences the phone while Liora is open.
///
/// Android 15 and later do not let an app change the global Do Not Disturb
/// switch. [NotificationManager.setInterruptionFilter] turns on a rule owned
/// by this app instead, and turning it off leaves the reader's own mode as it
/// was. Older versions change the global filter, so the previous value is
/// restored when Liora leaves the foreground.
object FocusMode {
    private const val PREFS = "focus_mode"
    private const val APPLIED = "applied"
    private const val PREVIOUS = "previous"

    fun hasAccess(context: Context): Boolean {
        val manager = notificationManager(context) ?: return false
        return manager.isNotificationPolicyAccessGranted
    }

    fun openSettings(activity: Activity): Boolean {
        return try {
            activity.startActivity(
                Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS),
            )
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }

    fun enable(context: Context): Boolean {
        val manager = notificationManager(context) ?: return false
        if (!manager.isNotificationPolicyAccessGranted) return false
        return try {
            if (usesOwnedRule()) {
                manager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALARMS)
                prefs(context).edit().putBoolean(APPLIED, true).apply()
                return true
            }
            val preferences = prefs(context)
            if (preferences.getBoolean(APPLIED, false)) {
                if (manager.currentInterruptionFilter == NotificationManager.INTERRUPTION_FILTER_ALL) {
                    manager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALARMS)
                }
                return true
            }
            val current = manager.currentInterruptionFilter
            if (current != NotificationManager.INTERRUPTION_FILTER_ALL) {
                return true
            }
            manager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALARMS)
            preferences.edit().putInt(PREVIOUS, current).putBoolean(APPLIED, true).apply()
            true
        } catch (_: SecurityException) {
            false
        }
    }

    fun disable(context: Context): Boolean {
        val manager = notificationManager(context) ?: return false
        if (!manager.isNotificationPolicyAccessGranted) return false
        val preferences = prefs(context)
        if (!preferences.getBoolean(APPLIED, false)) return true
        return try {
            if (usesOwnedRule()) {
                manager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
            } else if (manager.currentInterruptionFilter == NotificationManager.INTERRUPTION_FILTER_ALARMS) {
                val previous = preferences.getInt(
                    PREVIOUS,
                    NotificationManager.INTERRUPTION_FILTER_ALL,
                )
                manager.setInterruptionFilter(previous)
            }
            preferences.edit().putBoolean(APPLIED, false).apply()
            true
        } catch (_: SecurityException) {
            false
        }
    }

    private fun usesOwnedRule(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM
    }

    private fun notificationManager(context: Context): NotificationManager? {
        return context.getSystemService(NotificationManager::class.java)
    }

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
