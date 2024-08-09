import Flutter
import UIKit
import LocalAuthentication

public class LocalAuthSignaturePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "local_auth_signature", binaryMessenger: registrar.messenger())
        let instance = LocalAuthSignaturePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case SwiftLocalAuthSignatureMethod.CreateKeyPair:
            guard let args = call.arguments as? Dictionary<String, String> else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ArgsIsNull,
                        message: "Arguments is null",
                        details: nil
                    )
                )
                return
            }
            generateKeyPair(args: args, result: result)
            break
        case SwiftLocalAuthSignatureMethod.Sign:
            guard let args = call.arguments as? Dictionary<String, String> else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ArgsIsNull,
                        message: "Arguments is null",
                        details: nil
                    )
                )
                return
            }
            sign(args: args, result: result)
            break
        case SwiftLocalAuthSignatureMethod.isSupported:
            let context = LAContext()
            var error: NSError?
            
            // 判断设备是否支持生物识别
            let isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            
            // 如果支持，还可以进一步区分是 Face ID 还是 Touch ID
            if isBiometricAvailable {
                if context.biometryType == .faceID {
                    print("Device supports Face ID.")
                } else if context.biometryType == .touchID {
                    print("Device supports Touch ID.")
                } else {
                    print("Biometric authentication is available but not sure of the type.")
                }
            } else {
                print("Biometric authentication is not available.")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            result(isBiometricAvailable)
            break
        case SwiftLocalAuthSignatureMethod.getPrivateKey:
            guard let args = call.arguments as? Dictionary<String, String> else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ArgsIsNull,
                        message: "Arguments is null",
                        details: nil
                    )
                )
                return
            }
            guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.KeyIsNull,
                        message: "Key is null",
                        details: nil
                    )
                )
                return
            }
            let keyManager = KeyPairManager()
            let keyPair =  keyManager.get(name: key)
            let privateKey = keyPair?.privateKey?.toBase64()
            result(privateKey)
            break
        case SwiftLocalAuthSignatureMethod.getPublicKey:
            guard let args = call.arguments as? Dictionary<String, String> else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ArgsIsNull,
                        message: "Arguments is null",
                        details: nil
                    )
                )
                return
            }
            guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.KeyIsNull,
                        message: "Key is null",
                        details: nil
                    )
                )
                return
            }
            let keyManager = KeyPairManager()
            let keyPair =  keyManager.get(name: key)
            let publicKey = keyPair?.publicKey?.toBase64()
            result(publicKey)
            break
        case SwiftLocalAuthSignatureMethod.isKeyPairExists:
            guard let args = call.arguments as? Dictionary<String, String> else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ArgsIsNull,
                        message: "Arguments is null",
                        details: nil
                    )
                )
                return
            }
            guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.KeyIsNull,
                        message: "Key is null",
                        details: nil
                    )
                )
                return
            }
            let keyManager = KeyPairManager()
            let keyPair = keyManager.get(name: key)
            result(keyPair != nil)
            break
        case SwiftLocalAuthSignatureMethod.Verify:
            guard let args = call.arguments as? Dictionary<String, String> else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ArgsIsNull,
                        message: "Arguments is null",
                        details: nil
                    )
                )
                return
            }
            guard let reason = args[SwiftLocalAuthSignatureArgs.Reason] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ReasonIsNull,
                        message: "Reason is null",
                        details: nil
                    )
                )
                return
            }
            guard let payload = args[SwiftLocalAuthSignatureArgs.Payload] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.PayloadIsNull,
                        message: "Payload is null",
                        details: nil
                    )
                )
                return
            }
            guard let signature = args[SwiftLocalAuthSignatureArgs.Signature] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.SignatureIsNull,
                        message: "Signature is null",
                        details: nil
                    )
                )
                return
            }
            guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.KeyIsNull,
                        message: "Key is null",
                        details: nil
                    )
                )
                return
            }
            let signatureBiometricManager = BiometricSignatureManager()
            let verify = signatureBiometricManager.verify(key: key, message: payload, signature: signature)
            result(verify)
            break
        case SwiftLocalAuthSignatureMethod.deleteKeyPair:
            guard let args = call.arguments as? Dictionary<String, String> else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ArgsIsNull,
                        message: "Arguments is null",
                        details: nil
                    )
                )
                return
            }
            guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.KeyIsNull,
                        message: "Key is null",
                        details: nil
                    )
                )
                return
            }
            let keyManager = KeyPairManager()
            keyManager.removeKey(name: key)
            result(nil)
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func generateKeyPair(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
            result(
                FlutterError(
                    code: SwiftLocalAuthSignatureError.KeyIsNull,
                    message: "Key is null",
                    details: nil
                )
            )
            return
        }
        let keyManager = KeyPairManager()
        let keyPair = keyManager.getOrCreate(name: key)
        let publicKey = keyPair?.publicKey?.toBase64()
        let privateKey = keyPair?.privateKey?.toBase64()
        let dictionary: [String: String?] = [LocalAuthSignatureResponse.publicKey: publicKey,  LocalAuthSignatureResponse.privateKey: privateKey]
        result(dictionary)
    }
    private func sign(args: Dictionary<String, String>, result: @escaping FlutterResult){
        guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
            result(
                FlutterError(
                    code: SwiftLocalAuthSignatureError.KeyIsNull,
                    message: "Key is null",
                    details: nil
                )
            )
            return
        }
        guard let payload = args[SwiftLocalAuthSignatureArgs.Payload] else {
            result(
                FlutterError(
                    code: SwiftLocalAuthSignatureError.PayloadIsNull,
                    message: "Payload is null",
                    details: nil
                )
            )
            return
        }
        let signatureBiometricManager = BiometricSignatureManager()
        let signatureResult = signatureBiometricManager.sign(key: key, message: payload)
        if signatureResult.status == SignatureBiometricStatus.success {
            result(signatureResult.signature)
        } else {
            result(
                FlutterError(
                    code: signatureResult.status,
                    message: "Error is \(signatureResult.status)",
                    details: nil
                )
            )
        }
        
    }
}
