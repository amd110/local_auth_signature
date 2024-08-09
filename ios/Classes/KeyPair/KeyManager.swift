//
//  KeyManager.swift
//  local_auth_signature
//
//  Created by sudan on 09/08/2024.
//

import Foundation

public protocol KeyManager {
    func create(name: String) -> KeyPair?
    func get(name: String) -> KeyPair?
    func getOrCreate(name: String) -> KeyPair?
    func removeKey(name: String)
}
