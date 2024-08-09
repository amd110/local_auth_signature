import 'package:local_auth_signature/src/android_prompt_info.dart';
import 'package:local_auth_signature/src/ios_prompt_info.dart';
import 'package:local_auth_signature/src/key_pair.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'local_auth_signature_method_channel.dart';

abstract class LocalAuthSignaturePlatform extends PlatformInterface {
  /// Constructs a CcLocalAuthSignaturePlatform.
  LocalAuthSignaturePlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalAuthSignaturePlatform _instance = MethodChannelLocalAuthSignature();

  /// The default instance of [CcLocalAuthSignaturePlatform] to use.
  ///
  /// Defaults to [MethodChannelLocalAuthSignature].
  static LocalAuthSignaturePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CcLocalAuthSignaturePlatform] when
  /// they register themselves.
  static set instance(LocalAuthSignaturePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  // Future<bool> isAvailable() {
  //   throw UnimplementedError('isAvailable() has not been implemented.');
  // }

  Future<KeyPair?> createKeyPair(String keyStoreAlias) {
    throw UnimplementedError('createKeyPair() has not been implemented.');
  }

  Future<void> deleteKeyPair(String keyStoreAlias) {
    throw UnimplementedError('deleteKeyPair() has not been implemented.');
  }

  Future<String?> getPublicKey(String keyStoreAlias) {
    throw UnimplementedError('getPublicKey() has not been implemented.');
  }

  Future<String?> getPrivateKey(String keyStoreAlias) {
    throw UnimplementedError('getPrivateKey() has not been implemented.');
  }

  Future<bool> isKeyPairExists(String keyStoreAlias) {
    throw UnimplementedError('isKeyPairExists() has not been implemented.');
  }

  Future<String?> sign({
    required String keyStoreAlias,
    required String payload,
    required AndroidPromptInfo androidPromptInfo,
    required IOSPromptInfo iosPromptInfo,
  }) {
    throw UnimplementedError('sign() has not been implemented.');
  }

  Future<bool> verify({
    required String keyStoreAlias,
    required String payload,
    required String signature,
    required AndroidPromptInfo androidPromptInfo,
    required IOSPromptInfo iosPromptInfo,
  }) {
    throw UnimplementedError('verify() has not been implemented.');
  }
}
