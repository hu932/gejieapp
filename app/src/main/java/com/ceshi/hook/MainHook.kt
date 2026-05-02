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

        // 【终极空白测试】
        // 里面不写任何代码，不打印日志，不调用 XposedBridge，不调用任何 Handler
        // 如果这样勾选后依然白屏，说明防线在 "LSPosed框架注入" 这一层，而不是模块代码层。
        // 加固壳只要检测到进程被附加了 LSPosed 的特征（比如 maps 里的 .so，或者 ptrace 附加），就会直接白屏挂起。
    }
}
