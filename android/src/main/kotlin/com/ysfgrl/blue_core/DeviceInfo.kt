package com.ysfgrl.blue_core

import android.app.UiModeManager
import android.content.Context
import android.content.res.Configuration
import android.os.Build

/** Reads Android hardware and operating system metadata. */
internal class DeviceInfo(private val context: Context) {
    fun getDeviceInfo(): DeviceInfoMessage {
        val mode = (context.getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager)
            ?.currentModeType
        val type = when (mode) {
            Configuration.UI_MODE_TYPE_TELEVISION -> "tv"
            Configuration.UI_MODE_TYPE_WATCH -> "watch"
            Configuration.UI_MODE_TYPE_CAR -> "car"
            else -> if (context.resources.configuration.smallestScreenWidthDp >= 600) {
                "tablet"
            } else {
                "phone"
            }
        }
        return DeviceInfoMessage(
            platform = "android",
            type = type,
            name = "${Build.MANUFACTURER} ${Build.MODEL}".trim(),
            model = Build.MODEL,
            version = Build.VERSION.RELEASE,
        )
    }
}
