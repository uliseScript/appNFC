/*package com.mycompany.nfcapp

import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.os.ParcelUuid
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.2RealPeople.bluetooth/server"
    private val SERVICE_UUID = UUID.fromString("00009000-0000-1000-8000-00805f9b34fb")
    private val CHARACTERISTIC_UUID = UUID.fromString("00009001-0000-1000-8000-00805f9b34fb")
    private lateinit var bluetoothManager: BluetoothManager
    private lateinit var bluetoothAdapter: BluetoothAdapter
    private var advertiser: BluetoothLeAdvertiser? = null
    private var gattServer: BluetoothGattServer? = null
    private lateinit var characteristic: BluetoothGattCharacteristic
    private var connectedDevice: BluetoothDevice? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "verificarBluetooth" -> {
                    val isEnabled = BluetoothAdapter.getDefaultAdapter()?.isEnabled ?: false
                    result.success(isEnabled)
                }
                "iniciarServidor" -> {
                    iniciarServidor()
                    result.success("Servidor BLE iniciado")
                }
                "enviarDato" -> {
                    enviarDato()
                    result.success("Dato enviado como byte binario")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun iniciarServidor() {
        bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter

        if (!bluetoothAdapter.isEnabled || !bluetoothAdapter.isMultipleAdvertisementSupported) {
            Log.e("BLE", "Bluetooth no disponible o no soporta anuncios múltiples")
            return
        }

        advertiser = bluetoothAdapter.bluetoothLeAdvertiser
        gattServer = bluetoothManager.openGattServer(this, gattServerCallback)

        val service = BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        characteristic = BluetoothGattCharacteristic(
            CHARACTERISTIC_UUID,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PROPERTY_READ,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        val descriptor = BluetoothGattDescriptor(
            UUID.fromString("00002902-0000-1000-8000-00805f9b34fb"),
            BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
        )
        descriptor.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
        characteristic.addDescriptor(descriptor)
        service.addCharacteristic(characteristic)
        gattServer?.addService(service)

        iniciarAnuncio()
        Log.i("BLE", "Servidor y anuncio BLE iniciados")
    }

    private fun iniciarAnuncio() {
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTimeout(0)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()

        advertiser?.startAdvertising(settings, data, advertiseCallback)
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            Log.i("BLE", "✅ Anuncio BLE activo")
        }

        override fun onStartFailure(errorCode: Int) {
            Log.e("BLE", "❌ Error al anunciar BLE: $errorCode")
        }
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice?, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                connectedDevice = device
                Log.i("BLE", "🔌 Cliente conectado: ${device?.address}")
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                connectedDevice = null
                Log.i("BLE", "❌ Cliente desconectado")
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice?,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic?
        ) {
            if (characteristic?.uuid == CHARACTERISTIC_UUID) {
                val value = byteArrayOf(0x6B.toByte(), 0x00)
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, value)
                Log.i("BLE", "📤 Lectura: enviado [0x6B, 0x00]")
            }
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice?,
            requestId: Int,
            descriptor: BluetoothGattDescriptor?,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray?
        ) {
            if (descriptor?.uuid.toString().equals("00002902-0000-1000-8000-00805f9b34fb", ignoreCase = true)) {
                if (responseNeeded) {
                    gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
                }
            }
        }
    }

    private fun enviarDato() {
        if (connectedDevice == null) {
            Log.w("BLE", "⚠️ No hay cliente conectado.")
            return
        }
        val dato = byteArrayOf(0x6B.toByte(), 0x00)
        characteristic.value = dato
        val notificado = gattServer?.notifyCharacteristicChanged(connectedDevice, characteristic, false)
        Log.i("BLE", "📡 Enviado (notify): ${dato.joinToString(" ") { "0x%02X".format(it) }}")
    }
}
*/

package com.mycompany.nfcapp

import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.os.ParcelUuid
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.2RealPeople.bluetooth/server"
    private var bluetoothManager: BluetoothManager? = null
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private var gattServer: BluetoothGattServer? = null
    private lateinit var service: BluetoothGattService
    private lateinit var characteristic: BluetoothGattCharacteristic
    private var connectedDevice: BluetoothDevice? = null

    private val SERVICE_UUID: UUID = UUID.fromString("00009000-0000-1000-8000-00805f9b34fb")
    private val CHARACTERISTIC_UUID: UUID = UUID.fromString("00009001-0000-1000-8000-00805f9b34fb")

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger!!,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "verificarBluetooth" -> {
                    val adapter = BluetoothAdapter.getDefaultAdapter()
                    val isEnabled = adapter?.isEnabled == true
                    result.success(isEnabled)
                }

                "iniciarServidor" -> {
                    iniciarServidor()
                    result.success("Servidor iniciado")
                }

                "enviarDato" -> {
                    val valorHex = call.arguments as? String ?: "0x00"
                    val byte1 = try {
                        valorHex.removePrefix("0x").toInt(16).toByte()
                    } catch (e: Exception) {
                        Log.e("BLE", "❌ Formato inválido: $valorHex")
                        0x00.toByte()
                    }
                    val data = byteArrayOf(byte1, 0x00)
                    enviarDato(data)
                    result.success("Dato enviado: ${data.joinToString(" ") { "0x%02X".format(it) }}")
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun iniciarServidor() {
        bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter

        if (bluetoothAdapter?.isEnabled != true || !bluetoothAdapter!!.isMultipleAdvertisementSupported) {
            Log.e("BLE", "Bluetooth no disponible o sin soporte de anuncios")
            return
        }

        advertiser = bluetoothAdapter?.bluetoothLeAdvertiser
        gattServer = bluetoothManager?.openGattServer(this, gattServerCallback)

        service = BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        characteristic = BluetoothGattCharacteristic(
            CHARACTERISTIC_UUID,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PROPERTY_READ,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        service.addCharacteristic(characteristic)
        gattServer?.addService(service)

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setConnectable(true)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()

        advertiser?.startAdvertising(settings, data, advertiseCallback)
        Log.i("BLE", "🔊 Anuncio BLE iniciado")
    }

    private fun enviarDato(data: ByteArray) {
        if (connectedDevice == null) {
            Log.w("BLE", "⚠️ No hay dispositivo conectado.")
            return
        }

        characteristic.value = data
        gattServer?.notifyCharacteristicChanged(connectedDevice, characteristic, false)
        Log.i("BLE", "📤 Notificado: ${data.joinToString(" ") { "0x%02X".format(it) }}")
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice?, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                connectedDevice = device
                Log.i("BLE", "✅ Conectado: ${device?.address}")
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                Log.i("BLE", "❌ Desconectado")
                connectedDevice = null
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic
        ) {
            if (characteristic.uuid == CHARACTERISTIC_UUID) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, characteristic.value)
                Log.i("BLE", "📖 Lectura solicitada")
            }
        }
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            Log.i("BLE", "✅ Advertising iniciado correctamente")
        }

        override fun onStartFailure(errorCode: Int) {
            Log.e("BLE", "❌ Error al anunciar BLE: $errorCode")
        }
    }
}
