//
//  KeyChainManager.swift
//  local_auth_signature
//
//  Created by sudan on 09/08/2024.
//

import Foundation

public protocol KeyChainManager {
    func loadKey(name: String) -> KeyPair?
    func removeKey(name: String)
    func makeAndStoreKey(name: String) throws -> KeyPair
}
