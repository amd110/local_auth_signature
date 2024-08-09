import 'package:local_auth_signature/src/android_prompt_info.dart';
import 'package:local_auth_signature/src/ios_prompt_info.dart';
import 'package:local_auth_signature/src/key_pair.dart';

import 'local_auth_signature_platform_interface.dart';

export 'src/android_prompt_info.dart';

export 'src/ios_prompt_info.dart';

class LocalAuthSignature {
  Future<bool> isSupported() {
    return LocalAuthSignaturePlatform.instance.isSupported();
  }

  // Future<bool> isAvailable() {
  //   throw UnimplementedError('isAvailable() has not been implemented.');
  // }

  Future<KeyPair?> createKeyPair(String keyStoreAlias) {
    return LocalAuthSignaturePlatform.instance.createKeyPair(keyStoreAlias);
  }

  Future<void> deleteKeyPair(String keyStoreAlias) {
    return LocalAuthSignaturePlatform.instance.deleteKeyPair(keyStoreAlias);
  }

  Future<String?> getPublicKey(String keyStoreAlias) {
    return LocalAuthSignaturePlatform.instance.getPublicKey(keyStoreAlias);
  }

  Future<String?> getPrivateKey(String keyStoreAlias) {
    return LocalAuthSignaturePlatform.instance.getPrivateKey(keyStoreAlias);
  }

  Future<bool> isKeyPairExists(String keyStoreAlias) {
    return LocalAuthSignaturePlatform.instance.isKeyPairExists(keyStoreAlias);
  }

  Future<String?> sign({
    required String keyStoreAlias,
    required String payload,
    required AndroidPromptInfo androidPromptInfo,
    required IOSPromptInfo iosPromptInfo,
  }) {
    return LocalAuthSignaturePlatform.instance.sign(
        keyStoreAlias: keyStoreAlias,
        payload: payload,
        androidPromptInfo: androidPromptInfo,
        iosPromptInfo: iosPromptInfo);
  }

  Future<bool> verify({
    required String keyStoreAlias,
    required String payload,
    required String signature,
    required AndroidPromptInfo androidPromptInfo,
    required IOSPromptInfo iosPromptInfo,
  }) {
    return LocalAuthSignaturePlatform.instance.verify(
        keyStoreAlias: keyStoreAlias,
        payload: payload,
        signature: signature,
        androidPromptInfo: androidPromptInfo,
        iosPromptInfo: iosPromptInfo);
  }
}
