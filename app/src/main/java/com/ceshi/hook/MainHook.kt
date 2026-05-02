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

        // 避免太早介入导致壳在初始化时就检测到模块的 ClassLoader 异常
        // 我们利用 Handler 稍微延时打印，或者仅仅是让当前类不立即执行任何实质操作
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            XposedBridge.log("[$TAG] 进入 Shopee，准备注入 (延时加载测试)")
        }, 3000)

        // 警告：Shopee 拥有极强的商业加固（壳）和环境检测风控。
        // 全局 Hook `Throwable.getStackTrace`、`ClassLoader.loadClass` 或 `Method.getModifiers` 
        // 这种极底层的 Java 核心类，会被加固壳的 Native 层探针直接发现，并导致其主动触发白屏或崩溃。
        
        // 现代的防检测手段不应该在模块代码里去 Hook 底层类，而是应该交由环境级隐藏去处理：
        // 1. 使用 Kitsune Mask (Magisk Delta) 的 SuList / Shamiko 来隐藏 Root。
        // 2. 在 LSPosed 管理器中针对 Shopee 勾选你的模块后，确保 LSPosed 本身的隐藏设置正确。
        // 3. 隐藏各种管理器的应用图标。

        // 这里仅保留一个最安全的入口，你可以尝试先运行这个空模块。
        // 如果这个空模块开启后不再白屏，说明白屏 100% 是由于之前的那些底层 Hook 触发了壳的自杀机制。
        // 你后续要写业务 Hook，请直接 Hook 具体的业务类（比如登录页面的类），而千万不要去碰基础类。
        
        /* 
        try {
            XposedHelpers.findAndHookMethod(
                "com.shopee.app.ui.login.LoginActivity", // 替换为真实的类名
                lpparam.classLoader,
                "onCreate",
                android.os.Bundle::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        XposedBridge.log("[$TAG] 成功 Hook LoginActivity")
                    }
                }
            )
        } catch (e: Throwable) {
            XposedBridge.log("[$TAG] Hook 业务类失败: ${e.message}")
        }
        */
    }
}
