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

        XposedBridge.log("[$TAG] 进入 Shopee，准备进行后续业务 Hook")

        // 既然云机自带底层改机功能，且目前是 Android 14 系统，
        // 我们在 Java 层写的 Build 字段篡改不仅多余，还极易与云机底层的修改发生冲突，
        // 或者因为修改不彻底导致特征矛盾（比如 Java 层是 Pixel 7，Native 层还是云机的原始指纹），
        // 从而引发更高级别的风控拦截。
        //
        // 因此，我们把模块的环境伪装代码全部删除，将改机工作完全交给你的云机自带功能。
        // 这个模块现在回到了最干净的安全状态，用于后续你真正需要做业务 Hook (比如拦截请求、破解参数) 时使用。
        
        // --- 下面是你未来写真正业务 Hook 的安全位置 ---
        // try {
        //     XposedHelpers.findAndHookMethod(
        //         "com.shopee.app.ui.login.LoginActivity", 
        //         lpparam.classLoader,
        //         "onCreate",
        //         android.os.Bundle::class.java,
        //         object : XC_MethodHook() {
        //             override fun afterHookedMethod(param: MethodHookParam) {
        //                 XposedBridge.log("[$TAG] 成功 Hook 登录页")
        //             }
        //         }
        //     )
        // } catch (e: Throwable) {
        //     XposedBridge.log("[$TAG] Hook 业务类失败: ${e.message}")
        // }
    }
}
