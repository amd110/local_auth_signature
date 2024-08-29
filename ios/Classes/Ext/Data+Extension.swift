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


extension String {
    func fromBase64UrlSafe() -> String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // 添加回填充字符
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        
        return base64
    }
    
    func decodeBase64UrlSafe() -> Data? {
        let base64String = self.fromBase64UrlSafe()
        return Data(base64Encoded: base64String)
    }
}
