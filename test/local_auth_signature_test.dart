import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_signature/local_auth_signature.dart';
import 'package:local_auth_signature/local_auth_signature_method_channel.dart';
import 'package:local_auth_signature/local_auth_signature_platform_interface.dart';
import 'package:local_auth_signature/src/key_pair.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocalAuthSignaturePlatform
    with MockPlatformInterfaceMixin
    implements LocalAuthSignaturePlatform {
  @override
  Future<KeyPair?> createKeyPair(String keyStoreAlias) {
    // TODO: implement createKeyPair
    throw UnimplementedError();
  }

  @override
  Future<void> deleteKeyPair(String keyStoreAlias) {
    // TODO: implement deleteKeyPair
    throw UnimplementedError();
  }

  @override
  Future<String?> getPrivateKey(String keyStoreAlias) {
    // TODO: implement getPrivateKey
    throw UnimplementedError();
  }

  @override
  Future<String?> getPublicKey(String keyStoreAlias) {
    // TODO: implement getPublicKey
    throw UnimplementedError();
  }

  @override
  Future<bool> isKeyPairExists(String keyStoreAlias) {
    // TODO: implement isKeyPairExists
    throw UnimplementedError();
  }

  @override
  Future<bool> isSupported() {
    // TODO: implement isSupported
    throw UnimplementedError();
  }

  @override
  Future<String?> sign(
      {required String keyStoreAlias,
      required String payload,
      required AndroidPromptInfo androidPromptInfo,
      required IOSPromptInfo iosPromptInfo}) {
    // TODO: implement sign
    throw UnimplementedError();
  }

  @override
  Future<bool> verify(
      {required String keyStoreAlias,
      required String payload,
      required String signature,
      required AndroidPromptInfo androidPromptInfo,
      required IOSPromptInfo iosPromptInfo}) {
    // TODO: implement verify
    throw UnimplementedError();
  }

  @override
  Future<String> getBase64String(String data, int? flags) {
    // TODO: implement getBase64String
    throw UnimplementedError();
  }
}

void main() {
  final LocalAuthSignaturePlatform initialPlatform = LocalAuthSignaturePlatform.instance;

  test('$MethodChannelLocalAuthSignature is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLocalAuthSignature>());
  });

  // test('getPlatformVersion', () async {
  //   LocalAuthSignature localAuthSignaturePlugin = LocalAuthSignature();
  //   MockLocalAuthSignaturePlatform fakePlatform = MockLocalAuthSignaturePlatform();
  //   LocalAuthSignaturePlatform.instance = fakePlatform;
  //
  //   expect(await localAuthSignaturePlugin.getPlatformVersion(), '42');
  // });
}
