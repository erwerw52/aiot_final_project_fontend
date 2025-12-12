package com.example.aiot_final_project_fontend

import android.content.Context
import android.view.View
import android.opengl.GLSurfaceView
import io.flutter.plugin.platform.PlatformView
import ai.guiji.duix.sdk.client.render.DUIXTextureView

class DuixPlatformView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    private val textureView: DUIXTextureView = DUIXTextureView(context)

    init {
        // 配置 DUIXTextureView 用於 OpenGL ES 3.0 渲染
        textureView.setEGLContextClientVersion(3)
        textureView.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
        textureView.isOpaque = false
        textureView.renderMode = GLSurfaceView.RENDERMODE_WHEN_DIRTY
        textureView.layoutParams = android.view.ViewGroup.LayoutParams(
            android.view.ViewGroup.LayoutParams.MATCH_PARENT,
            android.view.ViewGroup.LayoutParams.MATCH_PARENT
        )
    }

    override fun getView(): View {
        return textureView
    }

    override fun dispose() {
        // 清理資源
    }

    fun getTextureView(): DUIXTextureView {
        return textureView
    }
}
