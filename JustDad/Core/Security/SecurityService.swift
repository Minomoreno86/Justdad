//
//  SecurityService.swift
//  SoloPapá - Security and encryption services
//
//  Handles Face ID/Touch ID, Keychain, and local encryption
//

import Foundation
import LocalAuthentication
import Security
import CommonCrypto

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
    
    // MARK: - Encryption/Decryption
    func generateEncryptionKey() -> String {
        let keyData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        return keyData.base64EncodedString()
    }
    
    func encryptData(_ data: Data, with key: String) -> Data? {
        guard let keyData = Data(base64Encoded: key) else { return nil }
        
        let keyLength = kCCKeySizeAES256
        let ivLength = kCCBlockSizeAES128
        
        guard keyData.count == keyLength else { return nil }
        
        let iv = Data((0..<ivLength).map { _ in UInt8.random(in: 0...255) })
        let cryptLength = size_t(data.count + ivLength)
        var cryptData = Data(count: cryptLength)
        
        let keyLengthSize = size_t(keyLength)
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options: CCOptions = UInt32(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(operation,
                               algorithm,
                               options,
                               keyBytes.bindMemory(to: UInt8.self).baseAddress, keyLengthSize,
                               ivBytes.bindMemory(to: UInt8.self).baseAddress,
                               dataBytes.bindMemory(to: UInt8.self).baseAddress, data.count,
                               cryptBytes.bindMemory(to: UInt8.self).baseAddress, cryptLength,
                               &numBytesEncrypted)
                    }
                }
            }
        }
        
        guard UInt32(cryptStatus) == UInt32(kCCSuccess) else { return nil }
        
        // Prepend IV to encrypted data
        return iv + cryptData.prefix(numBytesEncrypted)
    }
    
    func decryptData(_ encryptedData: Data, with key: String) -> Data? {
        guard let keyData = Data(base64Encoded: key) else { return nil }
        
        let keyLength = kCCKeySizeAES256
        let ivLength = kCCBlockSizeAES128
        
        guard keyData.count == keyLength,
              encryptedData.count > ivLength else { return nil }
        
        let iv = encryptedData.prefix(ivLength)
        let dataToDecrypt = encryptedData.dropFirst(ivLength)
        
        let cryptLength = size_t(dataToDecrypt.count)
        var decryptedData = Data(count: cryptLength)
        
        let keyLengthSize = size_t(keyLength)
        let operation: CCOperation = UInt32(kCCDecrypt)
        let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options: CCOptions = UInt32(kCCOptionPKCS7Padding)
        
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = decryptedData.withUnsafeMutableBytes { decryptedBytes in
            dataToDecrypt.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(operation,
                               algorithm,
                               options,
                               keyBytes.bindMemory(to: UInt8.self).baseAddress, keyLengthSize,
                               ivBytes.bindMemory(to: UInt8.self).baseAddress,
                               dataBytes.bindMemory(to: UInt8.self).baseAddress, dataToDecrypt.count,
                               decryptedBytes.bindMemory(to: UInt8.self).baseAddress, cryptLength,
                               &numBytesDecrypted)
                    }
                }
            }
        }
        
        guard UInt32(cryptStatus) == UInt32(kCCSuccess) else { return nil }
        
        return decryptedData.prefix(numBytesDecrypted)
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
