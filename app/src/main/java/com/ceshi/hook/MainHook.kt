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

        XposedBridge.log("[$TAG] 进入 Shopee，开始反检测注入")

        // 核心反检测 1：拦截异常堆栈里的 Xposed 关键字（Shopee 常用的检测手段）
        try {
            XposedHelpers.findAndHookMethod(
                Throwable::class.java,
                "getStackTrace",
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val stackTrace = param.result as? Array<StackTraceElement> ?: return
                        val newStackTrace = stackTrace.filter { element ->
                            val name = element.className.lowercase()
                            // 过滤掉所有包含 xposed/lsposed/sandhook/edxposed 的堆栈
                            !name.contains("xposed") &&
                            !name.contains("lsposed") &&
                            !name.contains("sandhook") &&
                            !name.contains("edxposed")
                        }.toTypedArray()
                        param.result = newStackTrace
                    }
                }
            )
            XposedBridge.log("[$TAG] 绕过异常堆栈检测 成功")
        } catch (e: Throwable) {
            XposedBridge.log("[$TAG] 绕过异常堆栈检测 失败: ${e.message}")
        }

        // 核心反检测 2：阻止 Shopee 加载我们的模块类
        try {
            XposedHelpers.findAndHookMethod(
                ClassLoader::class.java,
                "loadClass",
                String::class.java,
                Boolean::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun beforeHookedMethod(param: MethodHookParam) {
                        val className = param.args[0] as? String ?: return
                        val lowerName = className.lowercase()
                        if (lowerName.contains("xposed") || lowerName.contains("lsposed") || lowerName.contains("edxposed")) {
                            XposedBridge.log("[$TAG] 拦截 loadClass 探针: $className")
                            // 正确的做法是抛出 ClassNotFoundException，而不是返回 null
                            param.throwable = ClassNotFoundException(className)
                        }
                    }
                }
            )
            XposedBridge.log("[$TAG] 绕过 loadClass 检测 成功")
        } catch (e: Throwable) {
            XposedBridge.log("[$TAG] 绕过 loadClass 检测 失败: ${e.message}")
        }

        // 核心反检测 3：Modifier.isNative 全局 Hook 会导致系统崩溃和白屏，必须移除或针对性 Hook Method.getModifiers
        // 这里提供一种更安全的绕过方法：拦截 Method.getModifiers 返回值，而不是 Modifier.isNative
        try {
            XposedHelpers.findAndHookMethod(
                java.lang.reflect.Method::class.java,
                "getModifiers",
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val method = param.thisObject as? java.lang.reflect.Method ?: return
                        // 只有在检测我们自己 Hook 过的方法时，才去除 Native 标志
                        // 这里暂时去除所有方法的 Native 标志也会有风险，但比直接改 Modifier.isNative 安全些
                        // 更好的做法是仅对被检测的类去除
                        val modifiers = param.result as Int
                        if (Modifier.isNative(modifiers)) {
                            // 去除 Native 标志 (Xposed Hook的方法会带有 Native 标志)
                            param.result = modifiers and Modifier.NATIVE.inv()
                        }
                    }
                }
            )
            XposedBridge.log("[$TAG] 绕过 Method.getModifiers 检测 成功")
        } catch (e: Throwable) {
            XposedBridge.log("[$TAG] 绕过 Method.getModifiers 检测 失败: ${e.message}")
        }
    }
}
