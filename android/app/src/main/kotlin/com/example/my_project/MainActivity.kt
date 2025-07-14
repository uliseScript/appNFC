package com.mycompany.nfcapp

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.2RealPeople.bluetooth/server"
    private val APP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    private val SERVICE_NAME = "MyBTServer"

    private var isServerRunning = false
    private var clientOutputStream: OutputStream? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "iniciarServidor" -> {
                    if (!isServerRunning) {
                        isServerRunning = true
                        iniciarServidorBluetooth(result)
                    } else {
                        result.success("Servidor ya iniciado")
                    }
                }

                "enviarDato" -> {
                    val mensaje = call.arguments as? String
                    if (mensaje != null && clientOutputStream != null) {
                        try {
                            clientOutputStream!!.write((mensaje + "\n").toByteArray())
                            clientOutputStream!!.flush()
                            result.success("Enviado: $mensaje")
                        } catch (e: Exception) {
                            result.error("BT_ERROR", "Error al enviar: ${e.message}", null)
                        }
                    } else {
                        result.error("BT_ERROR", "No hay cliente conectado", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun iniciarServidorBluetooth(result: MethodChannel.Result) {
        val adapter = BluetoothAdapter.getDefaultAdapter()

        if (adapter == null || !adapter.isEnabled) {
            result.error("BT_ERROR", "Bluetooth no disponible o desactivado", null)
            return
        }

        /*val discoverableIntent = Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE).apply {
            putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 300)
        }
        startActivity(discoverableIntent)*/

        Thread {
            try {
                val serverSocket: BluetoothServerSocket =
                    adapter.listenUsingRfcommWithServiceRecord(SERVICE_NAME, APP_UUID)

                while (true) {
                    val socket: BluetoothSocket = serverSocket.accept()
                    clientOutputStream = socket.outputStream
                    val inputStream: InputStream = socket.inputStream

                    Handler(Looper.getMainLooper()).post {
                        println("Cliente conectado")
                    }

                    // Leer datos del cliente (opcional)
                    val buffer = ByteArray(1024)
                    var bytesLeidos = 0
                    try {
                        while (socket.isConnected && inputStream.read(buffer).also { bytesLeidos = it } != -1) {
                            val recibido = String(buffer, 0, bytesLeidos)
                            println("Cliente dijo: $recibido")
                        }
                    } catch (e: Exception) {
                        println("Cliente desconectado o error: ${e.message}")
                    }

                    socket.close()
                    clientOutputStream = null
                    Handler(Looper.getMainLooper()).post {
                        println("Cliente desconectado")
                    }
                }
            } catch (e: Exception) {
                Handler(Looper.getMainLooper()).post {
                    result.error("BT_ERROR", "Error en servidor: ${e.message}", null)
                }
            }
        }.start()

        Handler(Looper.getMainLooper()).post {
            result.success("Servidor iniciado, esperando conexiones...")
        }
    }
}
