package com.topday.secure.secure_notes_app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.provider.DocumentsContract
import android.view.WindowManager
import java.io.File

class MainActivity : FlutterActivity() {
    private val migrationFileChannel = "secure_notes/migration_file"
    private val saveFileRequestCode = 4201
    private val pickFileRequestCode = 4202
    private var pendingResult: MethodChannel.Result? = null
    private var pendingSaveBytes: ByteArray? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            migrationFileChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveFile" -> {
                    val fileName = call.argument<String>("fileName") ?: "secure-notes.snote"
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null) {
                        result.error("invalid_args", "Missing file bytes.", null)
                        return@setMethodCallHandler
                    }
                    saveMigrationFile(fileName, bytes, result)
                }
                "pickFile" -> pickMigrationFile(result)
                "getImportDirectory" -> result.success(getImportDirectory().absolutePath)
                "pickFileFromImportDirectory" -> pickMigrationFileFromImportDirectory(result)
                "deleteFile" -> {
                    val uri = call.argument<String>("uri")
                    result.success(deleteMigrationFile(uri))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveMigrationFile(
        fileName: String,
        bytes: ByteArray,
        result: MethodChannel.Result
    ) {
        if (!setPendingResult(result)) {
            return
        }
        pendingSaveBytes = bytes
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        launchFileIntent(intent, saveFileRequestCode)
    }

    private fun pickMigrationFile(result: MethodChannel.Result) {
        if (hasBrokenSystemFilePicker()) {
            result.error(
                "file_picker_unavailable",
                "System file picker is unavailable on this device.",
                null
            )
            return
        }
        if (!setPendingResult(result)) {
            return
        }
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
        }
        val fallback = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
        }
        launchFileIntent(intent, pickFileRequestCode, fallback)
    }

    private fun launchFileIntent(
        intent: Intent,
        requestCode: Int,
        fallback: Intent? = null
    ) {
        val result = pendingResult ?: return
        val candidate = when {
            intent.resolveActivity(packageManager) != null -> intent
            fallback?.resolveActivity(packageManager) != null -> fallback
            else -> null
        }
        if (candidate == null) {
            clearPendingOperation()
            result.error("file_picker_unavailable", "No file picker is available.", null)
            return
        }
        try {
            startActivityForResult(candidate, requestCode)
        } catch (error: ActivityNotFoundException) {
            clearPendingOperation()
            result.error("file_picker_unavailable", error.message, null)
        } catch (error: Exception) {
            clearPendingOperation()
            result.error("file_picker_failed", error.message, null)
        }
    }

    private fun setPendingResult(result: MethodChannel.Result): Boolean {
        if (pendingResult != null) {
            result.error("already_active", "A file operation is already active.", null)
            return false
        }
        pendingResult = result
        return true
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            saveFileRequestCode -> handleSaveFileResult(resultCode, data?.data)
            pickFileRequestCode -> handlePickFileResult(resultCode, data?.data)
        }
    }

    private fun handleSaveFileResult(resultCode: Int, uri: Uri?) {
        val result = pendingResult ?: return
        val bytes = pendingSaveBytes
        clearPendingOperation()
        if (resultCode != Activity.RESULT_OK || uri == null || bytes == null) {
            result.success(null)
            return
        }
        try {
            contentResolver.openOutputStream(uri)?.use { output ->
                output.write(bytes)
            }
            result.success(uri.toString())
        } catch (error: Exception) {
            result.error("save_failed", error.message, null)
        }
    }

    private fun handlePickFileResult(resultCode: Int, uri: Uri?) {
        val result = pendingResult ?: return
        clearPendingOperation()
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            val bytes = contentResolver.openInputStream(uri)?.use { input ->
                input.readBytes()
            } ?: ByteArray(0)
            val file = hashMapOf<String, Any>(
                "name" to (uri.lastPathSegment ?: ""),
                "uri" to uri.toString(),
                "bytes" to bytes
            )
            result.success(file)
        } catch (error: Exception) {
            result.error("pick_failed", error.message, null)
        }
    }

    private fun getImportDirectory(): File {
        val directory = File(getExternalFilesDir(null), "import")
        if (!directory.exists()) {
            directory.mkdirs()
        }
        return directory
    }

    private fun pickMigrationFileFromImportDirectory(result: MethodChannel.Result) {
        try {
            val file = getImportDirectory()
                .listFiles { item -> item.isFile && item.name.endsWith(".snote", ignoreCase = true) }
                ?.maxByOrNull { item -> item.lastModified() }
            if (file == null) {
                result.success(null)
                return
            }
            val data = hashMapOf<String, Any>(
                "name" to file.name,
                "uri" to file.toURI().toString(),
                "bytes" to file.readBytes()
            )
            result.success(data)
        } catch (error: Exception) {
            result.error("import_directory_failed", error.message, null)
        }
    }

    private fun deleteMigrationFile(uriText: String?): Boolean {
        if (uriText.isNullOrBlank()) {
            return false
        }
        return try {
            val uri = Uri.parse(uriText)
            if (uri.scheme == "file") {
                val path = uri.path ?: return false
                File(path).delete()
            } else {
                DocumentsContract.deleteDocument(contentResolver, uri)
            }
        } catch (_: Exception) {
            false
        }
    }

    private fun hasBrokenSystemFilePicker(): Boolean {
        val fingerprint = Build.FINGERPRINT.lowercase()
        return getSystemProperty("init.svc.ldinit") == "running" ||
            getSystemProperty("ro.boottime.ldinit").isNotBlank() ||
            fingerprint.contains("aosp_marlin")
    }

    private fun getSystemProperty(name: String): String {
        return try {
            val systemProperties = Class.forName("android.os.SystemProperties")
            val get = systemProperties.getMethod("get", String::class.java)
            get.invoke(null, name) as? String ?: ""
        } catch (_: Exception) {
            ""
        }
    }

    private fun clearPendingOperation() {
        pendingResult = null
        pendingSaveBytes = null
    }
}
