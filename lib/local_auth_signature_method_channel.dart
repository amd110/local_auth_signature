import 'dart:io';

import 'package:local_auth_signature/src/android_prompt_info.dart';
import 'package:local_auth_signature/src/ios_prompt_info.dart';
import 'package:local_auth_signature/src/key_pair.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_auth_signature_platform_interface.dart';

/// An implementation of [LocalAuthSignaturePlatform] that uses method channels.
class MethodChannelLocalAuthSignature extends LocalAuthSignaturePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('local_auth_signature');

  @override
  Future<bool> isSupported() async {
    return (await methodChannel.invokeMethod<bool>('isSupported')) ?? false;
  }

  // @override
  // Future<bool> isAvailable() async {
  //   return (await methodChannel.invokeMethod<bool>('isAvailable')) ?? false;
  // }

  @override
  Future<KeyPair?> createKeyPair(String keyStoreAlias) async {
    final response = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('createKeyPair', {'key': keyStoreAlias});
    final Map<String, String>? dictionary = response?.map((key, value) {
      return MapEntry(key as String, value != null ? value as String : '');
    });
    if (dictionary != null && dictionary.isNotEmpty) {
      return KeyPair(privateKey: dictionary['privateKey']!, publicKey: dictionary['publicKey']!);
    } else {
      return null;
    }
  }

  @override
  Future<String?> getPrivateKey(String keyStoreAlias) {
    return methodChannel.invokeMethod<String>('getPrivateKey', {'key': keyStoreAlias});
  }

  @override
  Future<String?> getPublicKey(String keyStoreAlias) {
    return methodChannel.invokeMethod<String>('getPublicKey', {'key': keyStoreAlias});
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
  Future<String?> sign({
    required String keyStoreAlias,
    required String payload,
    required AndroidPromptInfo androidPromptInfo,
    required IOSPromptInfo iosPromptInfo,
  }) async {
    if (Platform.isIOS) {
      return await methodChannel.invokeMethod<String>('sign', {
        'key': keyStoreAlias,
        'payload': payload,
        'reason': iosPromptInfo.reason,
      });
    } else {
      return await methodChannel.invokeMethod<String>('sign', {
        'key': keyStoreAlias,
        'payload': payload,
        'title': androidPromptInfo.title,
        'subtitle': androidPromptInfo.subtitle,
        'description': androidPromptInfo.description,
        'negativeButton': androidPromptInfo.negativeButton,
        'invalidatedByBiometricEnrollment': androidPromptInfo.invalidatedByBiometricEnrollment,
      });
    }
  }

  @override
  Future<bool> verify({
    required String keyStoreAlias,
    required String payload,
    required String signature,
    required AndroidPromptInfo androidPromptInfo,
    required IOSPromptInfo iosPromptInfo,
  }) async {
    if (Platform.isIOS) {
      return await methodChannel.invokeMethod<bool>('verify', {
            'key': keyStoreAlias,
            'payload': payload,
            'signature': signature,
            'reason': iosPromptInfo.reason,
          }) ??
          false;
    } else {
      return await methodChannel.invokeMethod<bool>('verify', {
            'key': keyStoreAlias,
            'payload': payload,
            'signature': signature,
            'title': androidPromptInfo.title,
            'subtitle': androidPromptInfo.subtitle,
            'description': androidPromptInfo.description,
            'negativeButton': androidPromptInfo.negativeButton,
            'invalidatedByBiometricEnrollment': androidPromptInfo.invalidatedByBiometricEnrollment,
          }) ??
          false;
    }
  }
}
