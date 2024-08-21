import 'local_auth_signature_platform_interface.dart';

class LocalAuthSignature {
  Future<String> createKeyPair({
    required String keyStoreAlias,
    bool userAuthenticationRequired = true,
    bool invalidatedByBiometricEnrollment = false,
  }) {
    return LocalAuthSignaturePlatform.instance.createKeyPair(
      keyStoreAlias: keyStoreAlias,
      userAuthenticationRequired: userAuthenticationRequired,
      invalidatedByBiometricEnrollment: invalidatedByBiometricEnrollment,
    );
  }

  Future<void> deleteKeyPair(String keyStoreAlias) {
    return LocalAuthSignaturePlatform.instance.deleteKeyPair(keyStoreAlias);
  }

  Future<String> getPublicKey(String keyStoreAlias) {
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
  }) {
    return LocalAuthSignaturePlatform.instance.sign(keyStoreAlias: keyStoreAlias, payload: payload);
  }

  Future<bool> verify({
    required String keyStoreAlias,
    required String payload,
    required String signature,
  }) {
    return LocalAuthSignaturePlatform.instance.verify(
      keyStoreAlias: keyStoreAlias,
      payload: payload,
      signature: signature,
    );
  }

  Future<String> getBase64String(String data, int? flags) {
    return LocalAuthSignaturePlatform.instance.getBase64String(data, flags);
  }
}
