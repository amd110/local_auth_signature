//
//  SignatureManager.swift
//  local_auth_signature
//
//  Created by sudan on 09/08/2024.
//

import Foundation

public protocol SignatureManager {
    func sign(key:String, algorithm: SecKeyAlgorithm, data: Data) -> SignatureResult
    func sign(key:String, message: String) -> SignatureResult
    func verify(key:String, message: String, signature: String) -> Bool
}
