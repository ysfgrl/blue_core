package com.ysfgrl.blue_core

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Handler
import android.os.Looper

internal class ConnectionStatus(context: Context) : OnConnectionStatusStreamHandler() {
    private val manager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private val handler = Handler(Looper.getMainLooper())
    private var callback: ConnectivityManager.NetworkCallback? = null
    private var sink: PigeonEventSink<List<String>>? = null

    fun read(): List<String> = types(manager.activeNetwork?.let { manager.getNetworkCapabilities(it) })

    private fun types(capabilities: NetworkCapabilities?): List<String> {
        if (capabilities == null) return listOf("none")
        val result = mutableListOf<String>()
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) result.add("wifi")
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) result.add("ethernet")
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) result.add("mobile")
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH)) result.add("bluetooth")
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) result.add("vpn")
        return result.ifEmpty { listOf("other") }
    }

    override fun onListen(arguments: Any?, events: PigeonEventSink<List<String>>) {
        onCancel(null)
        sink = events
        val listener = object : ConnectivityManager.NetworkCallback() {
            override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) {
                val values = types(capabilities)
                handler.post { if (sink === events) events.success(values) }
            }
            override fun onLost(network: Network) {
                handler.postDelayed({ if (sink === events) sendCurrent(events) }, 150)
            }
        }
        try {
            manager.registerDefaultNetworkCallback(listener)
            callback = listener
            sendCurrent(events)
        } catch (error: Exception) {
            events.error("connection-error", error.message, null)
            onCancel(null)
        }
    }

    private fun sendCurrent(events: PigeonEventSink<List<String>>) {
        try {
            events.success(read())
        } catch (error: Exception) {
            events.error("connection-error", error.message, null)
        }
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        callback?.let { runCatching { manager.unregisterNetworkCallback(it) } }
        callback = null
        handler.removeCallbacksAndMessages(null)
    }
}
