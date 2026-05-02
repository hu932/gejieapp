package com.ceshi.hook

import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage
import java.lang.reflect.Modifier

class MainHook : IXposedHookLoadPackage {

    companion object {
        private const val TAG = "LSDemo"
        private const val TARGET_PACKAGE = "com.shopee.tw"
    }

    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != TARGET_PACKAGE) return

        XposedBridge.log("[$TAG] 进入 Shopee，开始修改手机环境 (伪装为真机)")

        // 核心改机逻辑：通过反射直接修改 Build 类的静态变量，避免使用 Method Hook 触发壳的白屏检测
        try {
            // 伪装成 Google Pixel 7 (国际版标准真机)
            XposedHelpers.setStaticObjectField(android.os.Build::class.java, "BRAND", "google")
            XposedHelpers.setStaticObjectField(android.os.Build::class.java, "MANUFACTURER", "Google")
            XposedHelpers.setStaticObjectField(android.os.Build::class.java, "MODEL", "Pixel 7")
            XposedHelpers.setStaticObjectField(android.os.Build::class.java, "PRODUCT", "panther")
            XposedHelpers.setStaticObjectField(android.os.Build::class.java, "DEVICE", "panther")
            XposedHelpers.setStaticObjectField(android.os.Build::class.java, "HARDWARE", "panther")
            XposedHelpers.setStaticObjectField(android.os.Build::class.java, "BOARD", "panther")
            
            // 修改指纹，必须是合法的真机指纹格式
            val realFingerprint = "google/panther/panther:13/TQ3A.230805.001/10316531:user/release-keys"
            XposedHelpers.setStaticObjectField(android.os.Build::class.java, "FINGERPRINT", realFingerprint)

            // 修改系统版本
            XposedHelpers.setStaticObjectField(android.os.Build.VERSION::class.java, "RELEASE", "13")
            XposedHelpers.setStaticIntField(android.os.Build.VERSION::class.java, "SDK_INT", 33)

            XposedBridge.log("[$TAG] 静态设备特征 (Build) 伪造成功！当前机型: Pixel 7")
        } catch (e: Throwable) {
            XposedBridge.log("[$TAG] 静态设备特征伪造失败: ${e.message}")
        }

        // 针对 Settings.Secure 里的 Android ID 进行 Hook (有一定的白屏风险，如果不白屏则说明成功绕过)
        try {
            XposedHelpers.findAndHookMethod(
                android.provider.Settings.Secure::class.java,
                "getString",
                android.content.ContentResolver::class.java,
                String::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val key = param.args[1] as? String ?: return
                        if (key == android.provider.Settings.Secure.ANDROID_ID) {
                            // 随机生成一个符合格式的 16 位 16进制 Android ID，代替云机固定的 ID
                            val fakeAndroidId = "a1b2c3d4e5f67890" // 仅做演示，实际黑产会写随机生成算法
                            param.result = fakeAndroidId
                            XposedBridge.log("[$TAG] 成功拦截并修改 Android ID 为: $fakeAndroidId")
                        }
                    }
                }
            )
        } catch (e: Throwable) {
            XposedBridge.log("[$TAG] Android ID 拦截失败: ${e.message}")
        }
    }
}
