package com.example.aiot_final_project_fontend

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import android.content.Context
import android.opengl.GLSurfaceView
import ai.guiji.duix.sdk.client.DUIX
import ai.guiji.duix.sdk.client.Constant
import ai.guiji.duix.sdk.client.VirtualModelUtil
import ai.guiji.duix.sdk.client.render.DUIXRenderer
import ai.guiji.duix.sdk.client.render.DUIXTextureView
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.duix_sdk"
    private val EVENT_CHANNEL = "com.example.duix_sdk/events"
    private var duix: DUIX? = null
    private var renderer: DUIXRenderer? = null
    private var textureView: DUIXTextureView? = null
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 設置 MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    result.success(true)
                }
                "checkBaseConfig" -> {
                    val isReady = VirtualModelUtil.checkBaseConfig(applicationContext)
                    result.success(isReady)
                }
                "checkModel" -> {
                    val modelName = call.argument<String>("modelName") ?: ""
                    val isReady = VirtualModelUtil.checkModel(applicationContext, modelName)
                    result.success(isReady)
                }
                "downloadBaseConfig" -> {
                    val url = call.argument<String>("url") ?: ""
                    downloadBaseConfig(url, result)
                }
                "downloadModel" -> {
                    val modelUrl = call.argument<String>("modelUrl") ?: ""
                    downloadModel(modelUrl, result)
                }
                "initModel" -> {
                    val modelName = call.argument<String>("modelName") ?: ""
                    initDigitalHuman(modelName, result)
                }
                "release" -> {
                    releaseDigitalHuman()
                    result.success(true)
                }
                "playWavFile" -> {
                    val wavPath = call.argument<String>("wavFilePath") ?: ""
                    duix?.playAudio(wavPath)
                    result.success(true)
                }
                "playAudioBytes" -> {
                    val audioBytes = call.argument<ByteArray>("audioBytes")
                    val fileName = call.argument<String>("fileName") ?: "temp.wav"
                    if (audioBytes != null) {
                        playAudioFromBytes(audioBytes, fileName, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "audioBytes is null", null)
                    }
                }
                "stopAudio" -> {
                    duix?.stopAudio()
                    result.success(true)
                }
                "isModelReady" -> {
                    val ready = duix?.isReady() ?: false
                    result.success(ready)
                }
                "setVolume" -> {
                    val volume = call.argument<Double>("volume")?.toFloat() ?: 1.0f
                    duix?.setVolume(volume)
                    result.success(true)
                }
                "startPush" -> {
                    duix?.startPush()
                    result.success(true)
                }
                "pushPcm" -> {
                    val pcmData = call.argument<ByteArray>("pcmData")
                    if (pcmData != null) {
                        duix?.pushPcm(pcmData)
                    }
                    result.success(true)
                }
                "stopPush" -> {
                    duix?.stopPush()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 設置 EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        // 註冊 PlatformView
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "duix_platform_view",
            DigitalHumanViewFactory()
        )
    }

    private fun downloadBaseConfig(url: String, result: MethodChannel.Result) {
        VirtualModelUtil.baseConfigDownload(
            applicationContext,
            url,
            object : VirtualModelUtil.ModelDownloadCallback {
                override fun onDownloadProgress(url: String, current: Long, total: Long) {
                    sendEvent(mapOf(
                        "type" to "download_progress",
                        "category" to "base_config",
                        "current" to current,
                        "total" to total
                    ))
                }

                override fun onUnzipProgress(url: String, current: Long, total: Long) {
                    sendEvent(mapOf(
                        "type" to "unzip_progress",
                        "category" to "base_config",
                        "current" to current,
                        "total" to total
                    ))
                }

                override fun onDownloadComplete(url: String, dir: File) {
                    sendEvent(mapOf(
                        "type" to "download_complete",
                        "category" to "base_config"
                    ))
                    result.success(true)
                }

                override fun onDownloadFail(url: String, code: Int, msg: String) {
                    sendEvent(mapOf(
                        "type" to "download_fail",
                        "category" to "base_config",
                        "error" to msg
                    ))
                    result.error("DOWNLOAD_FAILED", msg, code)
                }
            }
        )
    }

    private fun downloadModel(modelUrl: String, result: MethodChannel.Result) {
        VirtualModelUtil.modelDownload(
            applicationContext,
            modelUrl,
            object : VirtualModelUtil.ModelDownloadCallback {
                override fun onDownloadProgress(url: String, current: Long, total: Long) {
                    sendEvent(mapOf(
                        "type" to "download_progress",
                        "category" to "model",
                        "current" to current,
                        "total" to total
                    ))
                }

                override fun onUnzipProgress(url: String, current: Long, total: Long) {
                    sendEvent(mapOf(
                        "type" to "unzip_progress",
                        "category" to "model",
                        "current" to current,
                        "total" to total
                    ))
                }

                override fun onDownloadComplete(url: String, dir: File) {
                    sendEvent(mapOf(
                        "type" to "download_complete",
                        "category" to "model"
                    ))
                    result.success(true)
                }

                override fun onDownloadFail(url: String, code: Int, msg: String) {
                    sendEvent(mapOf(
                        "type" to "download_fail",
                        "category" to "model",
                        "error" to msg
                    ))
                    result.error("DOWNLOAD_FAILED", msg, code)
                }
            }
        )
    }

    private fun initDigitalHuman(modelName: String, result: MethodChannel.Result) {
        mainHandler.post {
            try {
                // 創建渲染視圖
                textureView = DUIXTextureView(this)
                renderer = DUIXRenderer(this, textureView!!)

                textureView?.setEGLContextClientVersion(3)
                textureView?.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
                textureView?.isOpaque = false
                textureView?.setRenderer(renderer)
                textureView?.renderMode = GLSurfaceView.RENDERMODE_WHEN_DIRTY

                // 初始化 DUIX
                duix = DUIX(applicationContext, modelName, renderer) { event, msg, info ->
                    android.util.Log.d("MainActivity", "DUIX Callback: event=$event, msg=$msg")
                    when (event) {
                        Constant.CALLBACK_EVENT_INIT_READY -> {
                            sendEvent(mapOf("type" to "init_ready"))
                            result.success(true)
                        }
                        Constant.CALLBACK_EVENT_INIT_ERROR -> {
                            android.util.Log.e("MainActivity", "INIT_ERROR: $msg")
                            sendEvent(mapOf("type" to "init_error", "error" to msg))
                            result.success(false)
                        }
                        Constant.CALLBACK_EVENT_AUDIO_PLAY_START -> {
                            sendEvent(mapOf("type" to "play_start"))
                        }
                        Constant.CALLBACK_EVENT_AUDIO_PLAY_END -> {
                            sendEvent(mapOf("type" to "play_end"))
                        }
                        Constant.CALLBACK_EVENT_AUDIO_PLAY_ERROR -> {
                            android.util.Log.e("MainActivity", "AUDIO_PLAY_ERROR: $msg")
                            sendEvent(mapOf("type" to "play_error", "error" to msg))
                        }
                    }
                }

                duix?.init()
            } catch (e: Exception) {
                e.printStackTrace()
                sendEvent(mapOf("type" to "init_error", "error" to e.message))
                result.success(false)
            }
        }
    }

    private fun releaseDigitalHuman() {
        mainHandler.post {
            duix?.release()
            duix = null
            renderer = null
            textureView = null
        }
    }

    private fun playAudioFromBytes(audioBytes: ByteArray, fileName: String, result: MethodChannel.Result) {
        try {
            val tempFile = File(cacheDir, fileName)
            tempFile.writeBytes(audioBytes)
            duix?.playAudio(tempFile.absolutePath)
            result.success(true)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to play audio from bytes", e)
            result.error("PLAY_AUDIO_ERROR", e.message, null)
        }
    }

    private fun sendEvent(data: Map<String, Any?>) {
        mainHandler.post {
            eventSink?.success(data)
        }
    }

    override fun onDestroy() {
        releaseDigitalHuman()
        super.onDestroy()
    }

    // PlatformView Factory
    inner class DigitalHumanViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            return DigitalHumanPlatformView(context)
        }
    }

    // PlatformView 實現
    inner class DigitalHumanPlatformView(context: Context) : PlatformView {
        private val container: FrameLayout = FrameLayout(context)

        init {
            mainHandler.post {
                textureView?.let { view ->
                    (view.parent as? ViewGroup)?.removeView(view)
                    container.addView(view, FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT
                    ))
                }
            }
        }

        override fun getView(): FrameLayout = container

        override fun dispose() {
            container.removeAllViews()
        }
    }
}
