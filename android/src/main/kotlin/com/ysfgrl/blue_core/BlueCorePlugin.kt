package com.ysfgrl.blue_core

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

/** Reads metadata from the application hosting blue_core. */
class BlueCorePlugin : FlutterPlugin, BlueCoreApi {
    private var context: Context? = null
    private var connection: ConnectionStatus? = null
    private var connectionChannel: EventChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        connection = ConnectionStatus(binding.applicationContext)
        OnConnectionStatusStreamHandler.register(binding.binaryMessenger, checkNotNull(connection))
        // Retain a channel handle only to unregister when the engine detaches.
        connectionChannel = EventChannel(binding.binaryMessenger,
            "dev.flutter.pigeon.blue_core.BlueCoreConnectionEvents.onConnectionStatus",
            MessagesPigeonMethodCodec)
        BlueCoreApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        BlueCoreApi.setUp(binding.binaryMessenger, null)
        connection?.onCancel(null)
        connectionChannel?.setStreamHandler(null)
        connectionChannel = null
        connection = null
        context = null
    }

    override fun getPackageInfo(): PackageInfoMessage {
        val appContext = checkNotNull(context) {
            "BlueCorePlugin is not attached to an engine"
        }
        return Version(appContext).getPackageInfo()
    }

    override fun getDeviceInfo(): DeviceInfoMessage {
        val appContext = checkNotNull(context) {
            "BlueCorePlugin is not attached to an engine"
        }
        return DeviceInfo(appContext).getDeviceInfo()
    }

    override fun getConnectionStaus(callback: (Result<List<String>>) -> Unit) {
        callback(runCatching {
            checkNotNull(connection) { "BlueCorePlugin is not attached to an engine" }.read()
        })
    }
}
