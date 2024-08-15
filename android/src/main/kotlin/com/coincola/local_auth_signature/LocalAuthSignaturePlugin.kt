package com.coincola.local_auth_signature

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception
import java.nio.charset.Charset
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.PublicKey
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.concurrent.Executor

/** LocalAuthSignaturePlugin */

class LocalAuthSignaturePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var activity: FragmentActivity? = null

    private val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    private val utf8 = Charset.forName("UTF-8")

    private lateinit var executor: Executor

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        executor = ContextCompat.getMainExecutor(flutterPluginBinding.applicationContext)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "local_auth_signature")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            LocalAuthSignatureMethod.BASE64_ENCODE -> {
                val data = call.argument<String>("data")
                val flags = call.argument<Int>("flags")
                val base64Str = String(Base64.encode(data!!.toByteArray(), flags ?: Base64.DEFAULT))
                result.success(base64Str)
            }

            LocalAuthSignatureMethod.IS_SUPPORTED -> {
                isSupported(result)
            }

            LocalAuthSignatureMethod.CREATE_KEYPAIR -> {
                createKeyPair(call, result)
            }

            LocalAuthSignatureMethod.GET_PUBLIC_KEY -> {
                val keyStoreAlias = call.argument<String>(LocalAuthSignatureArgs.BIO_KEY)
                if (keyStoreAlias == null) {
                    result.error(LocalAuthSignatureError.KEY_IS_NULL, "keyStoreAlias is null", null)
                    return
                }
                val publicKey = getPublicKey(keyStoreAlias).encoded.toString(utf8)
                result.success(publicKey)
            }

            LocalAuthSignatureMethod.GET_PRIVATE_KEY -> {
                val keyStoreAlias = call.argument<String>(LocalAuthSignatureArgs.BIO_KEY)
                if (keyStoreAlias == null) {
                    result.error(LocalAuthSignatureError.KEY_IS_NULL, "keyStoreAlias is null", null)
                    return
                }
                val privateKey = getPrivateKey(keyStoreAlias).encoded.toString(utf8)
                result.success(privateKey)
            }

            LocalAuthSignatureMethod.IS_KEYPAIR_EXISTS -> {
                val keyStoreAlias = call.argument<String>(LocalAuthSignatureArgs.BIO_KEY)
                if (keyStoreAlias == null) {
                    result.error(LocalAuthSignatureError.KEY_IS_NULL, "keyStoreAlias is null", null)
                    return
                }
                result.success(isKeyPairExists(keyStoreAlias))
            }

            LocalAuthSignatureMethod.SIGN -> {
                sign(call, result)
            }

            LocalAuthSignatureMethod.VERIFY -> {
                verify(call, result)
            }

            LocalAuthSignatureMethod.DELETE_KEY_PAIR -> {
                try {
                    val keyStoreAlias = call.argument<String>(LocalAuthSignatureArgs.BIO_KEY)
                    keyStore.deleteEntry(keyStoreAlias)
                } catch (_: Exception) {

                }
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun isSupported(result: Result) {
        if (activity != null) {
            val biometricManager = BiometricManager.from(activity!!)
            val status =
                biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && status != BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE && status != BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED)
        } else {
            result.error(LocalAuthSignatureError.NO_FRAGMENT_ACTIVITY, "activity is null", null)
        }
    }


    private fun isKeyPairExists(keystoreAlias: String): Boolean {
        return keyStore.containsAlias(keystoreAlias)
    }

    private fun getPrivateKey(keystoreAlias: String): PrivateKey {
        return keyStore.getKey(keystoreAlias, null) as PrivateKey
    }

    /**
     * 获取验签的公钥
     */
    private fun getPublicKey(keystoreAlias: String): PublicKey {
        return keyStore.getCertificate(keystoreAlias).publicKey
    }

    @Suppress("DEPRECATION")
    private fun createKeyPair(call: MethodCall, result: Result) {
        val keyStoreAlias = call.argument<String>(LocalAuthSignatureArgs.BIO_KEY)
        if (keyStoreAlias == null) {
            result.error(LocalAuthSignatureError.KEY_IS_NULL, "keyStoreAlias is null", null)
            return
        }
        val map = mutableMapOf<String, String>()
        if (isKeyPairExists(keyStoreAlias)) {
//            map[LocalAuthSignatureResponse.PRIVATE_KEY] =
//                Base64.encodeToString(getPrivateKey(keyStoreAlias).encoded, Base64.DEFAULT)

            map[LocalAuthSignatureResponse.PUBLIC_KEY] =
                String(
                    Base64.encode(
                        getPublicKey(keyStoreAlias).encoded,
                        Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING
                    )
                )
        } else {
            val keyPairGenerator =
                KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
            keyPairGenerator.initialize(
                KeyGenParameterSpec.Builder(
                    keyStoreAlias,
                    KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
                ).apply {
                    setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                    setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512)
                    setUserAuthenticationRequired(true)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        setUserAuthenticationParameters(10, KeyProperties.AUTH_BIOMETRIC_STRONG)
                    } else {
                        setUserAuthenticationValidityDurationSeconds(10)
                    }
                }.build()
            )
            val keyPair = keyPairGenerator.generateKeyPair()

            map[LocalAuthSignatureResponse.PUBLIC_KEY] =
                String(
                    Base64.encode(
                        keyPair.public.encoded,
                        Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING
                    )
                )
        }

        result.success(map)
    }

    private fun sign(call: MethodCall, result: Result) {
        val keyStoreAlias = call.argument<String?>(LocalAuthSignatureArgs.BIO_KEY)
        val data = call.argument<String?>(LocalAuthSignatureArgs.BIO_PAYLOAD)
        if (keyStoreAlias == null) {
            result.error(LocalAuthSignatureError.KEY_IS_NULL, "keyStoreAlias is null", null)
            return
        }
        if (data == null) {
            result.error(LocalAuthSignatureError.PAYLOAD_IS_NULL, "payload is null", null)
            return
        }
        if (activity == null) {
            result.error(LocalAuthSignatureError.NO_FRAGMENT_ACTIVITY, "activity is null", null)
            return
        }
        val title = call.argument<String?>(LocalAuthSignatureArgs.BIO_TITLE) ?: ""
        val subtitle = call.argument<String?>(LocalAuthSignatureArgs.BIO_SUBTITLE) ?: ""
        val description = call.argument<String?>(LocalAuthSignatureArgs.BIO_DESCRIPTION)
        val negativeButton =
            call.argument<String?>(LocalAuthSignatureArgs.BIO_NEGATIVE_BUTTON) ?: ""
        try {
            authenticate(
                activity!!,
                title,
                subtitle,
                negativeButton,
                description,
                object : BiometricPrompt.AuthenticationCallback() {
                    override fun onAuthenticationSucceeded(authenticationResult: BiometricPrompt.AuthenticationResult) {
                        val signature = Signature.getInstance("SHA256withECDSA")
                        val privateKey = getPrivateKey(keyStoreAlias)
                        signature.initSign(privateKey)
                        signature.update(data.toByteArray())
                        val signatureData = String(
                            Base64.encode(
                                signature.sign(),
                                Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING
                            )
                        )
                        result.success(signatureData)
                    }

                    override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                        result.error(errorCode.toString(), errString.toString(), null)
                    }

                    override fun onAuthenticationFailed() {
                        result.error(LocalAuthSignatureError.ERROR, "onAuthenticationFailed", null)
                    }
                })

        } catch (e: Exception) {
            result.error(LocalAuthSignatureError.ERROR, e.message, e)
        }
    }

    private fun authenticate(
        activity: FragmentActivity,
        title: String,
        subtitle: String,
        negativeButtonText: String,
        description: String?,
        callback: BiometricPrompt.AuthenticationCallback,
    ) {
        val biometricPrompt = BiometricPrompt(activity, executor, callback)
        val promptInfo =
            BiometricPrompt.PromptInfo.Builder()
                .setTitle(title)
                .setSubtitle(subtitle)
                .setNegativeButtonText(negativeButtonText)
                .setDescription(description)
                .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
                .setConfirmationRequired(false)
                .build()
        biometricPrompt.authenticate(promptInfo)
    }

    private fun verify(call: MethodCall, result: Result) {
        val keyStoreAlias = call.argument<String?>(LocalAuthSignatureArgs.BIO_KEY)
        if (keyStoreAlias == null) {
            result.error(LocalAuthSignatureError.KEY_IS_NULL, "keyStoreAlias is null", null)
            return
        }
        val data = call.argument<String?>(LocalAuthSignatureArgs.BIO_PAYLOAD)
        if (data == null) {
            result.error(LocalAuthSignatureError.PAYLOAD_IS_NULL, "payload is null", null)
            return
        }
        val bioSignature = call.argument<String?>(LocalAuthSignatureArgs.BIO_SIGNATURE)
        if (bioSignature == null) {
            result.error(LocalAuthSignatureError.SIGNATURE_IS_NULL, "signature data is null", null)
            return
        }
        try {
            val signature = Signature.getInstance("SHA256withECDSA")
            signature.initVerify(getPublicKey(keyStoreAlias))
            signature.update(data.toByteArray())
            val respByte = Base64.decode(bioSignature, Base64.DEFAULT)
            result.success(signature.verify(respByte))
        } catch (e: Exception) {
            result.error(LocalAuthSignatureError.ERROR, e.message, e)
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
