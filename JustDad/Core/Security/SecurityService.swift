//
//  SecurityService.swift
//  SoloPapá - Security and encryption services
//
//  Handles Face ID/Touch ID, Keychain, and local encryption
//

import Foundation
import LocalAuthentication
import Security

class SecurityService: ObservableObject {
    static let shared = SecurityService()
    
    // MARK: - Biometric Authentication
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
        
        do {
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Accede a SoloPapá con Face ID o Touch ID"
            )
            return result
        } catch {
            print("Biometric authentication failed: \(error.localizedDescription)")
            return false
        }
    }
    
    func isBiometricAuthenticationAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func getBiometricType() -> LABiometryType {
        let context = LAContext()
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    // MARK: - Keychain Operations
    func saveToKeychain(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item if it exists
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func loadFromKeychain(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess ? result as? Data : nil
    }
    
    func deleteFromKeychain(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Encryption/Decryption (Placeholder for SQLCipher integration)
    func generateEncryptionKey() -> String {
        // TODO: Implement proper key generation for SQLCipher
        // This should generate a strong encryption key for database encryption
        let keyData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        return keyData.base64EncodedString()
    }
    
    func encryptData(_ data: Data, with key: String) -> Data? {
        // TODO: Implement AES encryption for local file encryption
        // This is a placeholder - implement proper AES encryption
        return data
    }
    
    func decryptData(_ encryptedData: Data, with key: String) -> Data? {
        // TODO: Implement AES decryption for local file decryption
        // This is a placeholder - implement proper AES decryption
        return encryptedData
    }
    
    // MARK: - App Lock State
    private let appLockStateKey = "app_lock_state"
    
    func saveAppLockState(_ isEnabled: Bool) {
        let data = Data([isEnabled ? 1 : 0])
        _ = saveToKeychain(key: appLockStateKey, data: data)
    }
    
    func getAppLockState() -> Bool {
        guard let data = loadFromKeychain(key: appLockStateKey),
              let byte = data.first else {
            return false
        }
        return byte == 1
    }
    
    // MARK: - Secure Data Cleanup
    func clearAllSecureData() {
        // TODO: Implement secure data cleanup
        // - Clear all keychain entries
        // - Securely delete encrypted files
        // - Clear app data
        
        let keysToDelete = [
            appLockStateKey,
            "encryption_key",
            "user_preferences"
        ]
        
        for key in keysToDelete {
            _ = deleteFromKeychain(key: key)
        }
        
        print("Secure data cleanup completed")
    }
}
