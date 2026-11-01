package com.somosliora.app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.io.InputStream
import java.util.ArrayDeque
import java.util.concurrent.Executors

internal const val openedEpubChannel = "com.somosliora.app/open_epub"

internal class OpenedEpubRelay : EventChannel.StreamHandler {
    private val pending = ArrayDeque<Map<String, String>>()
    private var sink: EventChannel.EventSink? = null

    fun emit(path: String, name: String) {
        val event = mapOf("path" to path, "name" to name)
        val events = sink
        if (events == null) {
            pending.add(event)
        } else {
            events.success(event)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
        while (pending.isNotEmpty()) {
            events.success(pending.removeFirst())
        }
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}

internal object OpenedEpubCapture {
    private val io = Executors.newSingleThreadExecutor()

    fun capture(activity: Activity, intent: Intent?, relay: OpenedEpubRelay) {
        if (intent?.action != Intent.ACTION_VIEW) return
        val uri = intent.data ?: return
        intent.action = Intent.ACTION_MAIN
        intent.data = null

        val cacheDir = activity.cacheDir
        // Cloud providers can block on the network, even for the display name.
        io.execute {
            val name = displayName(activity, uri)
            val filePath = if (uri.scheme == "file") uri.path else null
            val saved = if (filePath != null) {
                copyFile(File(filePath), cacheDir, name)
            } else {
                openStream(activity, uri)?.use { copyStream(it, cacheDir, name) }
            }
            if (saved == null) return@execute
            activity.runOnUiThread {
                if (!activity.isDestroyed) relay.emit(saved.first, saved.second)
            }
        }
    }

    private fun openStream(activity: Activity, uri: Uri): InputStream? {
        return try {
            activity.contentResolver.openInputStream(uri)
        } catch (_: Exception) {
            null
        }
    }

    private fun displayName(activity: Activity, uri: Uri): String {
        if (uri.scheme == "file") {
            return uri.lastPathSegment?.ifBlank { "book.epub" } ?: "book.epub"
        }
        return try {
            activity.contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                if (!cursor.moveToFirst()) return@use null
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index < 0) null else cursor.getString(index)
            }
        } catch (_: Exception) {
            null
        }?.ifBlank { null } ?: uri.lastPathSegment ?: "book.epub"
    }

    private fun copyFile(source: File, cacheDir: File, name: String): Pair<String, String>? {
        if (!source.isFile) return null
        return try {
            source.inputStream().use { copyStream(it, cacheDir, name) }
        } catch (_: Exception) {
            null
        }
    }

    private fun copyStream(
        stream: InputStream?,
        cacheDir: File,
        name: String,
    ): Pair<String, String>? {
        if (stream == null) return null
        val directory = File(cacheDir, "opened_epubs")
        if (!directory.exists() && !directory.mkdirs()) return null
        val destination = File(directory, cacheFileName(name))
        return try {
            destination.outputStream().use { output -> stream.copyTo(output) }
            if (!destination.isFile || destination.length() == 0L) {
                destination.delete()
                null
            } else {
                destination.absolutePath to fileTitle(name)
            }
        } catch (_: Exception) {
            destination.delete()
            null
        }
    }

    private fun fileTitle(name: String): String {
        val base = name.substringAfterLast('/').substringAfterLast('\\').trim()
        return base.ifBlank { "book.epub" }
    }

    private fun cacheFileName(name: String): String {
        val cleaned = fileTitle(name).filter { character ->
            character.isLetterOrDigit() || character == '.' || character == '-' ||
                character == '_' || character == ' '
        }
        val safe = cleaned.ifBlank { "book.epub" }
        val withExtension = if (safe.endsWith(".epub", ignoreCase = true)) {
            safe
        } else {
            "$safe.epub"
        }
        return "${System.nanoTime()}_$withExtension"
    }
}
