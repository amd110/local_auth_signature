//
//  CryptoManager.swift
//  local_auth_signature
//
//  Created by sudan on 29/08/2024.
//

import Foundation
import CommonCrypto
import LocalAuthentication

class CryptoManager {
    func createKeyPair(name: String) -> KeyPair? {
        let exists = keyPairExists(name:name)
        guard exists == false else {
            return KeyPair(privateKey: getPrivateKey(name: name), publicKey: getPublicKey(name:name))
        }
        
        let accessControl = SecAccessControlCreateWithFlags(nil,
                                                            kSecAttrAccessibleAfterFirstUnlock,
                                                            [],
                                                            nil)!
        let privateKeyAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: name.data(using: .utf8)!,
            kSecAttrAccessControl as String: accessControl
        ]
        
        let publicKeyAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: name.data(using: .utf8)!
        ]
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: privateKeyAttributes,
            kSecPublicKeyAttrs as String: publicKeyAttributes
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Failed to create private key: \(error!.takeRetainedValue() as Error)")
            return nil
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Failed to create public key")
            return nil
        }
        
        return KeyPair(privateKey: privateKey, publicKey: publicKey)
    }
    
    func keyPairExists(name:String) -> Bool {
        return getPrivateKey(name:name) != nil && getPublicKey(name:name) != nil
    }
    
    // 使用私钥签名数据
    func sign(data: Data, with privateKey: SecKey) -> SignatureResult {
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
        
        var error: Unmanaged<CFError>?
        let signature = SecKeyCreateSignature(
            privateKey, algorithm,
            data as CFData,
            &error
        ) as Data?
        
        if let error = error {
            print("Signing failed: \(error.takeRetainedValue() as Error)")
            return SignatureResult(signature: nil, status: SignatureBiometricStatus.error)
        }
        return SignatureResult(signature: signature?.toBase64(), status: SignatureBiometricStatus.success)

    }
    
    func verify(signature: Data, for data: Data, with publicKey: SecKey) -> Bool {
        var error: Unmanaged<CFError>?
        let isValid = SecKeyVerifySignature(publicKey,
                                            .ecdsaSignatureMessageX962SHA256,
                                            data as CFData,
                                            signature as CFData,
                                            &error)
        
        if let error = error {
            print("Verification failed: \(error.takeRetainedValue() as Error)")
            return false
        }
        
        return isValid
    }

    
    // 从 Keychain 获取私钥
    func getPrivateKey(name:String) -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: name.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status != errSecSuccess {
            print("Failed to get private key. Status: \(status)")
            if status == errSecItemNotFound {
                print("Private key not found in Keychain. Make sure generateKeyPair() was called.")
            }
            return nil
        }
        
        return (item as! SecKey)
    }
    
    // 从 Keychain 获取公钥
    func getPublicKey(name:String) -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: name.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            print("Failed to get public key: \(status)")
            return nil
        }
        
        return (item as! SecKey)
    }
    
    // 删除密钥对
    func deleteKeyPair(name:String) -> Bool {
        let privateKeyQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: name.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
        ]
        
        let publicKeyQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: name.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
        ]
        
        let privateKeyStatus = SecItemDelete(privateKeyQuery as CFDictionary)
        let publicKeyStatus = SecItemDelete(publicKeyQuery as CFDictionary)
        
        if privateKeyStatus == errSecSuccess && publicKeyStatus == errSecSuccess {
            print("Key pair deleted successfully")
            return true
        } else {
            print("Failed to delete key pair: Private key status: \(privateKeyStatus), Public key status: \(publicKeyStatus)")
            return false
        }
    }
    
    // 获取公钥数据
    func getPublicKeyData(name:String) -> Data? {
        guard let publicKey = getPublicKey(name: name) else {
            print("Failed to get public key")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            print("Failed to get public key data: \(error!.takeRetainedValue() as Error)")
            return nil
        }
        
        return publicKeyData
    }
    
}
