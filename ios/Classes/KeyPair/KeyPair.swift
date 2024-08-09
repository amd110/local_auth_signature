//
//  KeyPair.swift
//  local_auth_signature
//
//  Created by sudan on 09/08/2024.
//

import Foundation
import CommonCrypto

public struct KeyPair {
    public let privateKey: SecKey?
    public let publicKey: SecKey?
}
