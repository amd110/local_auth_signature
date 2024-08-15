//
//  String+Extension.swift
//  local_auth_signature
//
//  Created by sudan on 15/08/2024.
//

import Foundation


extension Data {
    func toBase64() -> String? {
        let b64 = self.base64EncodedString()

        return b64
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
}
