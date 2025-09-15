package com.example.example

import android.os.Bundle
import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore

class MainActivity : FlutterActivity() {
    private val CHANNEL = "secure_weather_channel"
    
    // Name of the encrypted shared preferences file
    private val SECURE_PREFS_FILE = "secure_weather_prefs"
    
    // Key for the API key in encrypted storage
    private val API_KEY_STORAGE_KEY = "weather_api_key"
    
    private var encryptedPrefs: EncryptedSharedPreferences? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initializeEncryptedStorage()
        
        // For testing purposes, store a default API key
        // In a real production app, you would get this from a secure source
        storeDefaultApiKeyIfNeeded()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            println("Received method call: ${call.method}")
            when (call.method) {
                "getApiKey" -> {
                    val apiKey = getApiKeyFromSecureStorage()
                    println("Returning API key to Flutter: \"$apiKey\"")
                    result.success(apiKey)
                }
                "storeApiKey" -> {
                    val apiKey = call.argument<String>("apiKey")
                    println("Storing API key from Flutter: \"$apiKey\"")
                    if (apiKey != null) {
                        storeApiKeyInSecureStorage(apiKey)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "API key is null", null)
                    }
                }
                else -> {
                    println("Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeEncryptedStorage() {
        try {
            // Create or retrieve the master key
            val masterKey = MasterKey.Builder(this, MasterKey.DEFAULT_MASTER_KEY_ALIAS)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build()

            // Create encrypted shared preferences
            encryptedPrefs = EncryptedSharedPreferences.create(
                this,
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

    private fun storeDefaultApiKeyIfNeeded() {
        try {
            val currentApiKey = encryptedPrefs?.getString(API_KEY_STORAGE_KEY, "")
            println("Current API key in storage: \"$currentApiKey\" (length: ${currentApiKey?.length})")
            if (currentApiKey.isNullOrEmpty()) {
                // Permanently store the API key in encrypted storage
                println("Storing default API key")
                storeApiKeyInSecureStorage("162d984ea8c348c1b84113333242604")
            } else {
                println("API key already exists in storage")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun getApiKeyFromSecureStorage(): String {
        return try {
            val apiKey = encryptedPrefs?.getString(API_KEY_STORAGE_KEY, "") ?: ""
            println("Retrieved API key from secure storage: \"$apiKey\" (length: ${apiKey.length})")
            apiKey
        } catch (e: Exception) {
            // Handle error appropriately
            e.printStackTrace()
            ""
        }
    }

    private fun storeApiKeyInSecureStorage(apiKey: String) {
        try {
            println("Storing API key in secure storage: \"$apiKey\" (length: ${apiKey.length})")
            encryptedPrefs?.edit()?.putString(API_KEY_STORAGE_KEY, apiKey)?.apply()
        } catch (e: Exception) {
            // Handle error appropriately
            e.printStackTrace()
        }
    }
}