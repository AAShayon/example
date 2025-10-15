import Flutter
import UIKit
import Security

public class SecureApiPlugin: NSObject, FlutterPlugin {
    private let apiKeyStorageKey = "enterprise_api_key"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "secure_enterprise_api", binaryMessenger: registrar.messenger())
        let instance = SecureApiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getApiKey":
            let apiKey = getApiKeyFromKeychain()
            result(apiKey)
        case "storeApiKey":
            if let args = call.arguments as? [String: Any],
               let apiKey = args["apiKey"] as? String {
                storeApiKeyInKeychain(apiKey)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "API key is null", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getApiKeyFromKeychain() -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: apiKeyStorageKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess,
           let data = item as? Data,
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }
        
        return ""
    }
    
    private func storeApiKeyInKeychain(_ apiKey: String) {
        let data = apiKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: apiKeyStorageKey,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
}