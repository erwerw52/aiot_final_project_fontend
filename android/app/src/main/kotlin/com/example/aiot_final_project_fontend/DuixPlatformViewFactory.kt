package com.example.aiot_final_project_fontend

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import ai.guiji.duix.sdk.client.render.DUIXTextureView

object DuixViewHolder {
    private var view: DuixPlatformView? = null
    private var callback: ((DUIXTextureView) -> Unit)? = null
    
    fun setView(view: DuixPlatformView) {
        this.view = view
        callback?.invoke(view.getTextureView())
    }
    
    fun getTextureView(onReady: (DUIXTextureView) -> Unit) {
        view?.getTextureView()?.let { onReady(it) } ?: run {
            callback = onReady
        }
    }
    
    fun clear() {
        view = null
        callback = null
    }
}

class DuixPlatformViewFactory(private val context: Context) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<String?, Any?>
        val platformView = DuixPlatformView(context, viewId, creationParams)
        DuixViewHolder.setView(platformView)
        return platformView
    }
}
