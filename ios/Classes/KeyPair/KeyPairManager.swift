//
//  KeyPairManager.swift
//  local_auth_signature
//
//  Created by sudan on 09/08/2024.
//

import Foundation

import CommonCrypto

public class KeyPairManager : KeyManager {
    public func removeKey(name: String) {
        keychainManager.removeKey(name: name)
    }
    
    private let keychainManager: KeyChainManager = KeyChainAccessManager()
    
    public func create(name:String) -> KeyPair? {
        do {
            let keyPair = try keychainManager.makeAndStoreKey(name: name)
            return keyPair
        } catch let error {
            print("Can't create key pair : \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func get(name:String) -> KeyPair? {
        let key = keychainManager.loadKey(name: name)
        return key
    }
    
    public func getOrCreate(name:String) -> KeyPair? {
        let key = keychainManager.loadKey(name: name)
        guard key == nil else {
            return key
        }
        
        let keyPair = self.create(name: name)
        guard keyPair != nil else {
            print("Can't create key pair")
            return nil
        }
        
        return keyPair
    }
    
    
}
