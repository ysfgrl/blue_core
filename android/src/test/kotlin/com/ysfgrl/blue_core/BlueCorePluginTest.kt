package com.ysfgrl.blue_core

import org.junit.Test

class BlueCorePluginTest {
    @Test(expected = IllegalStateException::class)
    fun getPackageInfo_requiresAttachedEngine() {
        BlueCorePlugin().getPackageInfo()
    }

    @Test(expected = IllegalStateException::class)
    fun getDeviceInfo_requiresAttachedEngine() {
        BlueCorePlugin().getDeviceInfo()
    }

}
