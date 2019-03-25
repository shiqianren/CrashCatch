# CrashCatch
iOS crash 闪退拦截
方法比较粗鲁 使用runtime处理以下crash 可能会导致闪退的情况
使用cateGory+NSOobject 分别实现了NSArray，NSMutableArry,NSString,NSMutableString,NSDictionary
NStimer,KVO ,KVC 等场景，可以扩展其他可能造成闪退的情况

上线后可开启捕获crashlog输出，同步服务器或者第三方bug统计平台
开发过程中默认关闭状态，避免错误遗漏

待实现场景：拦截的crash异常会导致的业务场景的bug处理
