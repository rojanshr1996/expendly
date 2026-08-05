package com.expendly.app

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.expendly.app/mediastore"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "writeToDownloads") {
                val filename = call.argument<String>("filename")
                val content = call.argument<String>("content")

                if (filename.isNullOrEmpty() || content == null) {
                    result.error("INVALID_ARGS", "Filename and content must not be null or empty", null)
                    return@setMethodCallHandler
                }

                try {
                    val savedPath = writeToDownloadsDirectory(filename, content)
                    result.success(savedPath)
                } catch (e: Exception) {
                    result.error("WRITE_FAILED", e.localizedMessage ?: e.toString(), null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun writeToDownloadsDirectory(filename: String, content: String): String {
        val bytes = content.toByteArray(Charsets.UTF_8)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = applicationContext.contentResolver
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI

            val basePrefix = filename.substringBeforeLast(".")

            val projection = arrayOf(MediaStore.Downloads._ID, MediaStore.Downloads.DISPLAY_NAME)
            val selection = "${MediaStore.Downloads.RELATIVE_PATH} LIKE ? AND (${MediaStore.Downloads.DISPLAY_NAME} = ? OR ${MediaStore.Downloads.DISPLAY_NAME} LIKE ?)"
            val selectionArgs = arrayOf("%Download/Expendly%", filename, "$basePrefix%.csv")

            val exactMatchUris = mutableListOf<Uri>()
            val derivativeUris = mutableListOf<Uri>()

            try {
                resolver.query(collection, projection, selection, selectionArgs, "${MediaStore.Downloads._ID} DESC")?.use { cursor ->
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Downloads._ID)
                    val nameColumn = cursor.getColumnIndexOrThrow(MediaStore.Downloads.DISPLAY_NAME)
                    while (cursor.moveToNext()) {
                        val id = cursor.getLong(idColumn)
                        val name = cursor.getString(nameColumn)
                        val uri = Uri.withAppendedPath(collection, id.toString())
                        if (name.equals(filename, ignoreCase = true)) {
                            exactMatchUris.add(uri)
                        } else {
                            derivativeUris.add(uri)
                        }
                    }
                }
            } catch (e: Exception) {
                // Ignore query errors, proceed to insert/fallback
            }

            // 1. Prioritize updating exact matching filename entry (e.g. expendly_backup_1_0_0.csv)
            for (uri in exactMatchUris) {
                try {
                    resolver.openOutputStream(uri, "wt")?.use { stream ->
                        stream.write(bytes)
                        stream.flush()
                    }
                    // Clean up extraneous duplicate files if possible (e.g. expendly_backup_1_0_0 (1).csv)
                    for (dupUri in derivativeUris) {
                        try { resolver.delete(dupUri, null, null) } catch (_: Exception) {}
                    }
                    return "/storage/emulated/0/Download/Expendly/$filename"
                } catch (e: Exception) {
                    // Try deleting old locked entry if overwriting failed
                    try { resolver.delete(uri, null, null) } catch (_: Exception) {}
                }
            }

            // 2. If exact match wasn't writable, try updating derivative entries (e.g. expendly_backup_1_0_0 (1).csv)
            for (uri in derivativeUris) {
                try {
                    resolver.openOutputStream(uri, "wt")?.use { stream ->
                        stream.write(bytes)
                        stream.flush()
                    }
                    return "/storage/emulated/0/Download/Expendly/$filename"
                } catch (e: Exception) {
                    try { resolver.delete(uri, null, null) } catch (_: Exception) {}
                }
            }

            // 3. No overwritable entry found. Insert a new MediaStore entry for this app instance
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, filename)
                put(MediaStore.Downloads.MIME_TYPE, "text/csv")
                put(MediaStore.Downloads.RELATIVE_PATH, "Download/Expendly/")
                put(MediaStore.Downloads.IS_PENDING, 1)
            }

            val itemUri = resolver.insert(collection, values)
                ?: throw IOException("Failed to create MediaStore entry for $filename")

            try {
                resolver.openOutputStream(itemUri, "w")?.use { stream ->
                    stream.write(bytes)
                    stream.flush()
                }

                values.clear()
                values.put(MediaStore.Downloads.IS_PENDING, 0)
                resolver.update(itemUri, values, null, null)

                return "/storage/emulated/0/Download/Expendly/$filename"
            } catch (e: Exception) {
                try { resolver.delete(itemUri, null, null) } catch (_: Exception) {}
                throw IOException("Failed writing bytes to MediaStore file: ${e.message}")
            }
        } else {
            val downloadDir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "Expendly")
            if (!downloadDir.exists()) downloadDir.mkdirs()

            val targetFile = File(downloadDir, filename)
            FileOutputStream(targetFile).use { stream ->
                stream.write(bytes)
                stream.flush()
            }
            return targetFile.absolutePath
        }
    }
}
