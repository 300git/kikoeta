package com.kikoeta.kikoeta_app

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

/**
 * Android 文件夹导入桥接。
 *
 * file_picker 的 getDirectoryPath 会把 SAF 的 tree URI 反解成
 * /storage/emulated/0/... 这样的路径，但 Android 10 起的分区存储既不允许应用
 * 按路径读取用户目录，也不允许读取其中的非媒体文件（.lrc/.ass 等），所以文件夹
 * 导入在 Android 上会失败。
 *
 * 这里改为走 SAF：ACTION_OPEN_DOCUMENT_TREE 授权后直接用 DocumentsContract 遍历
 * 目录树，把歌词/字幕文件镜像到应用缓存目录，再把该目录交给 Dart 侧与桌面端共用
 * 的导入流程。只使用平台自带 API，不引入额外的 androidx 依赖。
 */
class LyricsFolderImport(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "kikoeta/storage"

        // 与主 Activity 的其它 request code（1001 权限请求）区分开。
        private const val REQUEST_CODE = 0x4C59

        // 镜像根目录：位于应用缓存目录内，随缓存一起被系统回收。
        private const val MIRROR_DIR = "lyrics_import"

        private const val MIME_DIR = DocumentsContract.Document.MIME_TYPE_DIR

        /** 与 Dart 侧 LyricsLibraryService.supportedExtensions 保持一致。 */
        private val DEFAULT_EXTENSIONS = setOf("lrc", "txt", "srt", "vtt", "ass", "ssa")
    }

    private var pendingResult: MethodChannel.Result? = null
    private var extensions: Set<String> = DEFAULT_EXTENSIONS

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickLyricsFolder" -> pickLyricsFolder(call, result)
            "releaseLyricsFolder" -> {
                // 只删本次生成的镜像目录，失败时交给系统缓存回收。
                call.argument<String>("path")?.let { path -> File(path).deleteRecursively() }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun pickLyricsFolder(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "已经有一个文件夹选择窗口处于打开状态。", null)
            return
        }
        extensions = (call.argument<List<String>>("extensions") ?: emptyList())
            .map { it.removePrefix(".").lowercase() }
            .filter { it.isNotEmpty() }
            .toSet()
            .ifEmpty { DEFAULT_EXTENSIONS }
        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            // 选完立刻镜像，不需要持久化授权，避免占用系统的持久化 URI 配额。
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        try {
            activity.startActivityForResult(intent, REQUEST_CODE)
        } catch (error: Exception) {
            pendingResult = null
            result.error("no_picker", error.message, null)
        }
    }

    /** 由 MainActivity 转发；返回 true 表示这次结果属于本模块。 */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val result = pendingResult ?: return true
        pendingResult = null
        val treeUri = data?.data
        if (resultCode != Activity.RESULT_OK || treeUri == null) {
            result.success(null)
            return true
        }
        // 遍历与拷贝都可能很慢，放到后台线程；结果回到主线程再交给 Flutter。
        Thread {
            try {
                val selection = mirror(treeUri)
                activity.runOnUiThread { result.success(selection) }
            } catch (error: Exception) {
                activity.runOnUiThread {
                    result.error("mirror_failed", error.message ?: "读取所选文件夹失败。", null)
                }
            }
        }.start()
        return true
    }

    /**
     * 把选中的目录树镜像到缓存目录，只保留歌词/字幕文件。
     *
     * 镜像根目录沿用用户所选文件夹的名字，导入流程据此识别作品号（例如
     * “RJ123456 作品名”）。
     */
    private fun mirror(treeUri: Uri): Map<String, Any?> {
        val root = File(activity.cacheDir, MIRROR_DIR)
        root.deleteRecursively()
        val treeDocumentId = DocumentsContract.getTreeDocumentId(treeUri)
        val target = File(root, sanitize(displayName(treeUri, treeDocumentId) ?: "lyrics"))
        val fileCount = copyTree(treeUri, treeDocumentId, target)
        return mapOf("path" to target.absolutePath, "fileCount" to fileCount)
    }

    private fun copyTree(treeUri: Uri, documentId: String, target: File): Int {
        if (!target.isDirectory && !target.mkdirs()) {
            throw IOException("无法创建缓存目录：${target.path}")
        }
        var copied = 0
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, documentId)
        query(
            children,
            arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                DocumentsContract.Document.COLUMN_MIME_TYPE,
            ),
        )?.use { cursor ->
            // 部分提供方返回的列顺序/数量与请求不一致，按列名取值。
            val idColumn = cursor.getColumnIndexOrThrow(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            )
            val nameColumn = cursor.getColumnIndexOrThrow(
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            )
            val mimeColumn = cursor.getColumnIndexOrThrow(
                DocumentsContract.Document.COLUMN_MIME_TYPE,
            )
            while (cursor.moveToNext()) {
                val childId = cursor.getString(idColumn) ?: continue
                val name = cursor.getString(nameColumn) ?: continue
                val mimeType = cursor.getString(mimeColumn) ?: ""
                if (mimeType == MIME_DIR) {
                    copied += copyTree(treeUri, childId, File(target, sanitize(name)))
                    continue
                }
                if (name.substringAfterLast('.', "").lowercase() !in extensions) continue
                val source = DocumentsContract.buildDocumentUriUsingTree(treeUri, childId)
                val destination = File(target, sanitize(name))
                activity.contentResolver.openInputStream(source)?.use { input ->
                    destination.outputStream().use { output -> input.copyTo(output) }
                    copied++
                }
            }
        }
        return copied
    }

    private fun displayName(treeUri: Uri, documentId: String): String? {
        val documentUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId)
        return query(
            documentUri,
            arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
        )?.use { cursor ->
            if (!cursor.moveToFirst()) {
                null
            } else {
                cursor.getString(
                    cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
                )
            }
        }
    }

    private fun query(uri: Uri, projection: Array<String>): Cursor? =
        activity.contentResolver.query(uri, projection, null, null, null)

    /** 目录项名字不可能含分隔符，这里只做防御，避免镜像出到目标之外。 */
    private fun sanitize(name: String): String {
        val cleaned = name.replace('/', '_').replace('\\', '_').trim()
        return cleaned.ifEmpty { "entry" }
    }
}
