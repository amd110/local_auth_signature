//
//  SignatureBiometricStatus.swift
//  local_auth_signature
//
//  Created by sudan on 09/08/2024.
//

import Foundation

public class SignatureBiometricStatus {
    public static let success = "success"
    public static let error = "Error"
    public static let passcodeNotSet = "PasscodeNotSet"
    public static let notEnrolled = "NotEnrolled"
    public static let lockedOut = "LockedOut"
    public static let notPaired = "NotPaired"
    public static let disconnected = "Disconnected"
    public static let invalidDimensions = "InvalidDimensions"
    public static let notAvailable = "NotAvailable"
    public static let userFallback = "UserFallback"
    public static let authenticationFailed = "AuthenticationFailed"
    public static let canceled = "Canceled"
    public static let notEvaluatePolicy = "NotEvaluatePolicy"
}
