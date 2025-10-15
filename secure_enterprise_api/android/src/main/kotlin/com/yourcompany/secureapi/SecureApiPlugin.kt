package com.yourcompany.secureapi

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SecureApiPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var encryptedPrefs: EncryptedSharedPreferences? = null
    private val SECURE_PREFS_FILE = "secure_enterprise_prefs"
    private val API_KEY_STORAGE_KEY = "enterprise_api_key"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "secure_enterprise_api")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        initializeEncryptedStorage()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getApiKey" -> {
                val apiKey = getApiKeyFromSecureStorage()
                result.success(apiKey)
            }
            "storeApiKey" -> {
                val apiKey = call.argument<String>("apiKey")
                if (apiKey != null) {
                    storeApiKeyInSecureStorage(apiKey)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "API key is null", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initializeEncryptedStorage() {
        try {
            // Create or retrieve the master key
            val masterKey = MasterKey.Builder(context, MasterKey.DEFAULT_MASTER_KEY_ALIAS)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build()

            // Create encrypted shared preferences
            encryptedPrefs = EncryptedSharedPreferences.create(
                context,
                SECURE_PREFS_FILE,
                masterKey,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            ) as EncryptedSharedPreferences
        } catch (e: Exception) {
            // Handle error appropriately
            e.printStackTrace()
        }
    }

    private fun getApiKeyFromSecureStorage(): String {
        return try {
            encryptedPrefs?.getString(API_KEY_STORAGE_KEY, "") ?: ""
        } catch (e: Exception) {
            // Handle error appropriately
            e.printStackTrace()
            ""
        }
    }

    private fun storeApiKeyInSecureStorage(apiKey: String) {
        try {
            encryptedPrefs?.edit()?.putString(API_KEY_STORAGE_KEY, apiKey)?.apply()
        } catch (e: Exception) {
            // Handle error appropriately
            e.printStackTrace()
        }
    }
}