package com.example.aiot_final_project_fontend

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import ai.guiji.duix.sdk.client.DUIX
import ai.guiji.duix.sdk.client.Callback
import ai.guiji.duix.sdk.client.VirtualModelUtil
import ai.guiji.duix.sdk.client.Constant
import ai.guiji.duix.sdk.client.render.DUIXRenderer

class DuixSdkHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "DuixSdkHandler"
        private const val CHANNEL_NAME = "com.example.duix_sdk"
        private const val EVENT_CHANNEL_NAME = "com.example.duix_sdk/events"
    }

    private var duixInstance: DUIX? = null
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    fun registerWith(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }
    
    private fun sendEvent(data: Map<String, Any?>) {
        mainHandler.post {
            eventSink?.success(data)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> handleInitialize(result)
            "checkBaseConfig" -> handleCheckBaseConfig(result)
            "checkModel" -> handleCheckModel(call, result)
            "downloadBaseConfig" -> handleDownloadBaseConfig(call, result)
            "downloadModel" -> handleDownloadModel(call, result)
            "initModel" -> handleInitModel(call, result)
            "isModelReady" -> handleIsModelReady(result)
            "startPush" -> handleStartPush(result)
            "pushPcm" -> handlePushPcm(call, result)
            "stopPush" -> handleStopPush(result)
            "playWavFile" -> handlePlayWavFile(call, result)
            "playAudioBytes" -> handlePlayAudioBytes(call, result)
            "stopAudio" -> handleStopAudio(result)
            "setVolume" -> handleSetVolume(call, result)
            "release" -> handleRelease(result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(result: MethodChannel.Result) {
        try {
            // 初始化已完成
            Log.d(TAG, "DUIX SDK initialized")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize DUIX SDK", e)
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun handleCheckBaseConfig(result: MethodChannel.Result) {
        try {
            val isDownloaded = VirtualModelUtil.checkBaseConfig(context)
            Log.d(TAG, "Base config exists: $isDownloaded")
            result.success(isDownloaded)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to check base config", e)
            result.error("CHECK_ERROR", e.message, null)
        }
    }

    private fun handleCheckModel(call: MethodCall, result: MethodChannel.Result) {
        val modelName = call.argument<String>("modelName")

        if (modelName.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENT", "Model name cannot be null or empty", null)
            return
        }

        try {
            val isDownloaded = VirtualModelUtil.checkModel(context, modelName)
            Log.d(TAG, "Model '$modelName' exists: $isDownloaded")
            result.success(isDownloaded)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to check model", e)
            result.error("CHECK_ERROR", e.message, null)
        }
    }

    private fun handleDownloadBaseConfig(call: MethodCall, result: MethodChannel.Result) {
        val customUrl = call.argument<String>("url")

        VirtualModelUtil.baseConfigDownload(context, object : VirtualModelUtil.ModelDownloadCallback {
            override fun onDownloadProgress(url: String, current: Long, total: Long) {
                Log.d(TAG, "Base config download progress: $current/$total")
                sendEvent(mapOf(
                    "type" to "download_progress",
                    "category" to "base_config",
                    "current" to current,
                    "total" to total
                ))
            }

            override fun onUnzipProgress(url: String, current: Long, total: Long) {
                Log.d(TAG, "Base config unzip progress: $current/$total")
                sendEvent(mapOf(
                    "type" to "unzip_progress",
                    "category" to "base_config",
                    "current" to current,
                    "total" to total
                ))
            }

            override fun onDownloadComplete(url: String, dir: java.io.File) {
                Log.d(TAG, "Base config download completed: ${dir.absolutePath}")
                sendEvent(mapOf(
                    "type" to "download_complete",
                    "category" to "base_config"
                ))
                mainHandler.post {
                    result.success(true)
                }
            }

            override fun onDownloadFail(url: String, code: Int, msg: String) {
                Log.e(TAG, "Base config download failed: $code, $msg")
                sendEvent(mapOf(
                    "type" to "download_fail",
                    "category" to "base_config",
                    "error" to msg
                ))
                mainHandler.post {
                    result.error("DOWNLOAD_ERROR", msg, code)
                }
            }
        })
    }

    private fun handleDownloadModel(call: MethodCall, result: MethodChannel.Result) {
        val modelUrl = call.argument<String>("modelUrl")

        if (modelUrl.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENT", "Model URL cannot be null or empty", null)
            return
        }

        VirtualModelUtil.modelDownload(context, modelUrl, object : VirtualModelUtil.ModelDownloadCallback {
            override fun onDownloadProgress(url: String, current: Long, total: Long) {
                Log.d(TAG, "Model download progress: $current/$total")
                sendEvent(mapOf(
                    "type" to "download_progress",
                    "category" to "model",
                    "current" to current,
                    "total" to total
                ))
            }

            override fun onUnzipProgress(url: String, current: Long, total: Long) {
                Log.d(TAG, "Model unzip progress: $current/$total")
                sendEvent(mapOf(
                    "type" to "unzip_progress",
                    "category" to "model",
                    "current" to current,
                    "total" to total
                ))
            }

            override fun onDownloadComplete(url: String, dir: java.io.File) {
                Log.d(TAG, "Model download completed: ${dir.absolutePath}")
                sendEvent(mapOf(
                    "type" to "download_complete",
                    "category" to "model"
                ))
                mainHandler.post {
                    result.success(true)
                }
            }

            override fun onDownloadFail(url: String, code: Int, msg: String) {
                Log.e(TAG, "Model download failed: $code, $msg")
                sendEvent(mapOf(
                    "type" to "download_fail",
                    "category" to "model",
                    "error" to msg
                ))
                mainHandler.post {
                    result.error("DOWNLOAD_ERROR", msg, code)
                }
            }
        })
    }

    private fun handleInitModel(call: MethodCall, result: MethodChannel.Result) {
        val modelName = call.argument<String>("modelName")

        if (modelName.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENT", "Model name cannot be null or empty", null)
            return
        }

        try {
            DuixViewHolder.getTextureView { textureView ->
                mainHandler.post {
                    try {
                        // 創建 DUIXRenderer
                        val renderer = DUIXRenderer(context as android.app.Activity, textureView)
                        textureView.setRenderer(renderer)
                        
                        // 創建 DUIX 實例
                        duixInstance = DUIX(context, modelName, renderer) { event, msg, info ->
                            Log.d(TAG, "DUIX event: $event, message: $msg")
                            
                            val eventType = when (event) {
                                Constant.CALLBACK_EVENT_INIT_READY -> "init_ready"
                                Constant.CALLBACK_EVENT_INIT_ERROR -> "init_error"
                                Constant.CALLBACK_EVENT_AUDIO_PLAY_START -> "play_start"
                                Constant.CALLBACK_EVENT_AUDIO_PLAY_END -> "play_end"
                                Constant.CALLBACK_EVENT_AUDIO_PLAY_ERROR -> "play_error"
                                else -> "unknown"
                            }
                            
                            sendEvent(mapOf(
                                "type" to eventType,
                                "message" to msg,
                                "error" to if (event.contains("ERROR")) msg else null
                            ))
                        }
                        
                        // 初始化模型 - 立即返回成功，實際完成狀態透過 EventChannel 通知
                        duixInstance?.init()
                        Log.d(TAG, "DUIX init() called, waiting for CALLBACK_EVENT_INIT_READY...")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to initialize DUIX model", e)
                        result.error("INIT_MODEL_ERROR", e.message, null)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get texture view", e)
            result.error("VIEW_ERROR", e.message, null)
        }
    }

    private fun handleIsModelReady(result: MethodChannel.Result) {
        val isReady = duixInstance?.isReady() ?: false
        result.success(isReady)
    }

    private fun handleStartPush(result: MethodChannel.Result) {
        try {
            duixInstance?.startPush()
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start push", e)
            result.error("PUSH_ERROR", e.message, null)
        }
    }

    private fun handlePushPcm(call: MethodCall, result: MethodChannel.Result) {
        val pcmData = call.argument<ByteArray>("pcmData")

        if (pcmData == null) {
            result.error("INVALID_ARGUMENT", "PCM data cannot be null", null)
            return
        }

        try {
            duixInstance?.pushPcm(pcmData)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to push PCM data", e)
            result.error("PUSH_ERROR", e.message, null)
        }
    }

    private fun handleStopPush(result: MethodChannel.Result) {
        try {
            duixInstance?.stopPush()
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop push", e)
            result.error("PUSH_ERROR", e.message, null)
        }
    }

    private fun handlePlayWavFile(call: MethodCall, result: MethodChannel.Result) {
        val wavFilePath = call.argument<String>("wavFilePath")

        if (wavFilePath.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENT", "WAV file path cannot be null or empty", null)
            return
        }

        try {
            duixInstance?.playAudio(wavFilePath)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to play WAV file", e)
            result.error("PLAY_ERROR", e.message, null)
        }
    }

    private fun handleStopAudio(result: MethodChannel.Result) {
        try {
            val stopped = duixInstance?.stopAudio() ?: false
            result.success(stopped)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop audio", e)
            result.error("STOP_ERROR", e.message, null)
        }
    }

    private fun handlePlayAudioBytes(call: MethodCall, result: MethodChannel.Result) {
        val audioBytes = call.argument<ByteArray>("audioBytes")
        val fileName = call.argument<String>("fileName") ?: "temp_audio.wav"
        
        if (audioBytes == null) {
            result.error("INVALID_ARGUMENT", "Audio bytes cannot be null", null)
            return
        }
        
        try {
            val tempFile = java.io.File(context.cacheDir, fileName)
            tempFile.writeBytes(audioBytes)
            
            Log.d(TAG, "Audio saved to: ${tempFile.absolutePath}, size: ${audioBytes.size}")
            duixInstance?.playAudio(tempFile.absolutePath)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to play audio bytes", e)
            result.error("PLAY_ERROR", e.message, null)
        }
    }

    private fun handleSetVolume(call: MethodCall, result: MethodChannel.Result) {
        val volume = (call.argument<Any>("volume") as? Number)?.toDouble() ?: 1.0

        try {
            duixInstance?.setVolume(volume.toFloat())
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set volume", e)
            result.error("VOLUME_ERROR", e.message, null)
        }
    }

    private fun handleRelease(result: MethodChannel.Result) {
        try {
            duixInstance?.release()
            duixInstance = null
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to release DUIX SDK", e)
            result.error("RELEASE_ERROR", e.message, null)
        }
    }
    
    fun release() {
        duixInstance?.release()
        duixInstance = null
        eventSink = null
    }
}