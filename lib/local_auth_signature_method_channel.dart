import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_auth_signature_platform_interface.dart';

/// An implementation of [LocalAuthSignaturePlatform] that uses method channels.
class MethodChannelLocalAuthSignature extends LocalAuthSignaturePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('local_auth_signature');

  @override
  Future<String> createKeyPair({
    required String keyStoreAlias,
    bool userAuthenticationRequired = true,
    bool invalidatedByBiometricEnrollment = false,
  }) async {
    final String? publicKey;
    if (Platform.isAndroid) {
      publicKey = await methodChannel.invokeMethod<String>('createKeyPair', {
        'key': keyStoreAlias,
        'userAuthenticationRequired': userAuthenticationRequired,
        'invalidatedByBiometricEnrollment': invalidatedByBiometricEnrollment
      });
    } else {
      publicKey = await methodChannel.invokeMethod<String>('createKeyPair', {'key': keyStoreAlias});
    }

    return publicKey!;
  }

  @override
  Future<String?> getPrivateKey(String keyStoreAlias) {
    return methodChannel.invokeMethod<String>('getPrivateKey', {'key': keyStoreAlias});
  }

  @override
  Future<String> getPublicKey(String keyStoreAlias) async {
    return (await methodChannel.invokeMethod<String>('getPublicKey', {'key': keyStoreAlias}))!;
  }

  @override
  Future<bool> isKeyPairExists(String keyStoreAlias) async {
    return (await methodChannel.invokeMethod<bool>('isKeyPairExists', {'key': keyStoreAlias})) ??
        false;
  }

  @override
  Future<void> deleteKeyPair(String keyStoreAlias) {
    return methodChannel.invokeMethod<void>('deleteKeyPair', {'key': keyStoreAlias});
  }

  @override
  Future<String> sign({
    required String keyStoreAlias,
    required String payload,
  }) async {
    return (await methodChannel.invokeMethod<String>('sign', {
      'key': keyStoreAlias,
      'payload': payload,
    }))!;
  }

  @override
  Future<bool> verify({
    required String keyStoreAlias,
    required String payload,
    required String signature,
  }) async {
    return await methodChannel.invokeMethod<bool>('verify', {
          'key': keyStoreAlias,
          'payload': payload,
          'signature': signature,
        }) ??
        false;
  }

  @override
  Future<String> getBase64String(String data, int? flags) async {
    return (await methodChannel.invokeMethod<String>(
            'base64Encode', {'data': data, if (flags != null) 'flags': flags})) ??
        '';
  }
}
