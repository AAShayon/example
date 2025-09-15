import Flutter
import UIKit
import Security

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "secure_weather_channel"
    private let apiKeyKey = "weather_api_key"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Set up the method channel
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "getApiKey":
                let apiKey = self?.getApiKeyFromKeychain() ?? ""
                // For testing purposes, return default key if none is stored
                if apiKey.isEmpty {
                    result("162d984ea8c348c1b84113333242604")
                } else {
                    result(apiKey)
                }
            case "storeApiKey":
                if let args = call.arguments as? [String: Any],
                   let apiKey = args["apiKey"] as? String {
                    self?.storeApiKeyInKeychain(apiKey)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "API key is null", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        // For testing purposes, store a default API key if none exists
        storeDefaultApiKeyIfNeeded()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func getApiKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: apiKeyKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    private func storeApiKeyInKeychain(_ apiKey: String) {
        let data = apiKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: apiKeyKey,
            kSecValueData as String: data
        ]
        
        // Try to update first
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        
        // If update failed, try to add
        if status == errSecItemNotFound {
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    private func storeDefaultApiKeyIfNeeded() {
        let currentApiKey = getApiKeyFromKeychain()
        if currentApiKey == nil || currentApiKey!.isEmpty {
            // Store the default API key for testing
            // In a real production app, you would get this from a more secure source
            storeApiKeyInKeychain("162d984ea8c348c1b84113333242604")
        }
    }
}
