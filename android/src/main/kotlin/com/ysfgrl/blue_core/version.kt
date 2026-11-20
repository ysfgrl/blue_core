package com.ysfgrl.blue_core

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build

/** Reads version and package metadata from the application hosting blue_core. */
internal class Version(private val context: Context) {
    @Suppress("DEPRECATION")
    fun getPackageInfo(): PackageInfoMessage {
        try {
            val manager = context.packageManager
            val packageName = context.packageName
            val info = manager.getPackageInfo(packageName, 0)
            val buildNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                info.longVersionCode
            } else {
                info.versionCode.toLong()
            }
            return PackageInfoMessage(
                appName = context.applicationInfo.loadLabel(manager).toString(),
                packageName = packageName,
                version = info.versionName.orEmpty(),
                buildNumber = buildNumber.toString(),
            )
        } catch (error: PackageManager.NameNotFoundException) {
            throw IllegalStateException("Unable to read application package info", error)
        }
    }
}
