import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth_signature/local_auth_signature.dart';
import 'package:local_auth_signature_example/card_box.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _localAuthSignature = LocalAuthSignature();
  final _key = 'coincola.test.key';
  final _payload = 'Hello';
  String? _publicKey = '';
  String? _signature =
      'MEUCIBIcOQng5BqDg9tOjayHDMPgiZT48bWJ0AzkSM0WGVcmAiEAkEGVzlZeJuJCz2IUnqJ/c1zzla1TErcnyU1nzkkN/dA=';
  String? _verified = '';
  String? _status = '';

  void _checkIsBiometricChanged() async {
    final status = await _localAuthSignature.isSupported();
    setState(() {
      _status = status.toString();
    });
  }

  void _createKeyPair() async {
    try {
      final publicKey = (await _localAuthSignature.createKeyPair(_key))?.publicKey;
      setState(() {
        _publicKey = publicKey;
      });
      print('publicKey: $publicKey');
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code}');
    }
  }

  void _sign() async {
    try {
      final signature = await _localAuthSignature.sign(
        keyStoreAlias: _key,
        payload: _payload,
        androidPromptInfo: AndroidPromptInfo(
          title: 'BIOMETRIC',
          subtitle: 'Please allow biometric',
          negativeButton: 'CANCEL',
          invalidatedByBiometricEnrollment: true,
        ),
        iosPromptInfo: IOSPromptInfo(reason: 'Please allow biometric'),
      );
      setState(() {
        _signature = signature;
      });
      print('signature: $signature');
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code}');
    }
  }

  void _verify() async {
    try {
      final verified = await _localAuthSignature.verify(
        keyStoreAlias: _key,
        payload: _payload,
        signature: _signature!,
        androidPromptInfo: AndroidPromptInfo(
          title: 'BIOMETRIC',
          subtitle: 'Please allow biometric',
          negativeButton: 'CANCEL',
          invalidatedByBiometricEnrollment: true,
        ),
        iosPromptInfo: IOSPromptInfo(reason: 'Please allow biometric'),
      );
      setState(() {
        _verified = '$verified';
      });
      print('verified: $verified');
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code}');
    }
  }

  void _deleteKeyPair() async {
    try {
      await _localAuthSignature.deleteKeyPair(_key);
      setState(() {
        _publicKey = '';
      });
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('PublicKey'),
                const SizedBox(height: 16),
                CardBox(child: Text('$_publicKey')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createKeyPair,
                  child: const Text('Create KeyPair'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _deleteKeyPair,
                  child: const Text('Delete KeyPair'),
                ),
                const Text('Biometric Changed'),
                const SizedBox(height: 16),
                CardBox(child: Text('$_status')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _checkIsBiometricChanged,
                  child: const Text('Check Biometric Changed'),
                ),
                const SizedBox(height: 16),
                const Text('Signature'),
                const SizedBox(height: 16),
                CardBox(child: Text('$_signature')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _sign,
                  child: const Text('Sign'),
                ),
                const SizedBox(height: 16),
                const Text('Verify'),
                const SizedBox(height: 16),
                CardBox(child: Text('$_verified')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _verify,
                  child: const Text('Verify'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
