<h2>Flutter Windows编写桌面端工具快速定位</h2>

&emsp;&emsp;Native Crash具有出错信息模糊、难以捕捉等特点，想比比JavaCrash难修复和定位。本篇介绍集成BreakPad用Flutter生成桌面端工具提高bug定位的效率。

<h5>一、定位本地崩溃问题</h5>

首先，在JNI层模拟个空指针赋值的崩溃，如下：

![image](https://user-images.githubusercontent.com/13035820/184601361-65da9cf2-b008-440c-bc31-6ccce6474f01.png)

Logcat的错误日志如下所示。

![image](https://user-images.githubusercontent.com/13035820/184601425-6db26c72-ffe9-4dad-ab18-33e4f6f07e5c.png)
![image](https://user-images.githubusercontent.com/13035820/184601456-7194081e-7bfb-4be3-9ead-46b3a790fc5d.png)

我们可以看到signal 11 (SIGSEGV), code 1 (SEGV_MAPERR)，看错误信号能知道当前错误类型为内存地址错误。



&emsp;&emsp;信号机制是Linux进程间通信的一种重要方式，Linux信号一方面用于正常的进程间通信和同步，如任务控制（SIGINT，SIGTSTP，SIGKILL，SIGCONT）它还负责监控系统异常及中断。

&emsp;&emsp;当应用程序运行异常时，Linux内核将产生错误信号并通知当前进程。当前进程在接收到该错误信号后，可以有三种不同的处理方式。

忽略该信号。捕捉该信号并执行对应的信号处理函数（信号处理程序）。执行该信号的缺省操作（如SIGSEGV，其缺省操作是终止进程）。

![image](https://user-images.githubusercontent.com/13035820/184601565-582ba1a3-8222-4e4b-b8f1-ba5c0afb3214.png)

如果我们想不通过Logcat，或者想将错误信息上传或者存储本地， 比较高效的获取崩溃日志，我们有几个方案可选择。

1.Bugly（腾讯）

2.xCrash（爱奇艺）

3.BreakPad（谷歌）

由于我们开发过程只需要本地的崩溃报错定位，所以选择谷歌的BreakPad方案获取日志。


<br/>
<h5>二、 BreakPad的使用</h5>

&emsp;&emsp;Google 开源 的 BreakPad，目前 Native 崩溃捕获中最为成熟的方案，当然还有爱奇艺的方案可供参考。可以理解为该库只是为了方便获取崩溃的墓碑文件。

breakpad官方源码：https://chromium.googlesource.com/breakpad/breakpad/+/master

将源码导入到AS 进行cmake编译后，得到动态库文件。

1 初始化操作

![image](https://user-images.githubusercontent.com/13035820/184601647-91aca5f2-810c-486f-a720-0a82bf597c1f.png)

初始化操作比较简单，只需要一行，传入日志的输出路径即可。然后我们模拟崩溃之后，会看到文件夹下的dmp文件。

![image](https://user-images.githubusercontent.com/13035820/184601700-146d003c-c230-4237-be51-a63adff0fdf9.png)

或者，一般默认墓碑文件位于路径/ data / tombstones /下。墓碑文件的获取可以通过 adb bugreport来进行获取，结合ndk-stack分析。

![image](https://user-images.githubusercontent.com/13035820/184601740-bb236b51-ea20-477e-8a91-d7b2081e28b2.png)
![image](https://user-images.githubusercontent.com/13035820/184601797-f0ea9698-24e8-499e-97cf-88de59f06ed9.png)

也可以直接用ndk-stack直接将logcat的错误日志堆栈打出来，如下命令：

adb logcat | ndk-stack -sym  C:\E_Dev\AndroidProject\DemoProject\app\build\intermediates\cmake\debug\obj\armeabi-v7a

结果如下，一样能得到崩溃日志地址信息：


![image](https://user-images.githubusercontent.com/13035820/184601858-e12e876e-62d4-4175-83b5-11a6f05c22da.png)

2 墓碑文件转换

breakpad源码下载下来，在breakpad/src/processor/minidump_stackwalk目录有个转换工具。

执行如下命令：

minidump_stackwalk C:\Users\admin\Desktop\bug\a.dmp >crash.txt  输出崩溃日志：

![image](https://user-images.githubusercontent.com/13035820/184601910-41dfde8d-4eb1-4132-a367-0fbfeaf2527c.png)

图中0x5f0为崩溃行内存地址。执行add2line命令后能正确定位。

![image](https://user-images.githubusercontent.com/13035820/184601970-b288d512-1463-47f9-a178-c3ede25de150.png)


3 工具定位错误

&emsp;&emsp;借助 ndk-stack 工具，您可以使用符号来表示来自 adb logcat 的堆栈轨迹或 /data/tombstones/ 中的 Tombstone。该工具会将共享库内的任何地址替换为源代码中对应的 <source-file>:<line-number>，从而简化调试流程。

&emsp;&emsp;我们利用ndk-stack工具获取崩溃对应行数。这个工具能自动分析tombstone文件，能将崩溃时的调用内存地址和c ++代码一行一行对应起来。

官方说明：https://developer.android.google.cn/ndk/guides/ndk-stack

<h5>输入如下命令：</h5>

<h5>adb logcat | ndk-stack -sym  C:\E_Dev\AndroidProject\DemoProject\app\build\intermediates\cmake\debug\obj\arm64-v8a</h5>

 ![image](https://user-images.githubusercontent.com/13035820/184602068-dd8e1072-86bc-484b-bcc4-ef6a4fc19685.png)
找到了是nativeCrash的265行报错。
 
 ![image](https://user-images.githubusercontent.com/13035820/184604546-4d970deb-67c5-405a-a7f0-346a4691f09a.png)


或者我们可以利用arm-linux-androideabi-addr2line工具找到报错地址。在之前的崩溃日志拿到地址为 0000000000015ed0。

我们执行如下代码：

aarch64-linux-android-addr2line -f -C -e  C:\E_Dev\AndroidProject\DemoProject\app\build\intermediates\cmake\debug\obj\arm64-v8a\libnative-lib.so 0000000000015ed0

输出如下：
 ![image](https://user-images.githubusercontent.com/13035820/184604595-3c80200b-957f-43b5-aa9b-31494ee881d2.png)


同样能拿到对应的报错行数。

注意：

这里说一下为什么用cmake下的so不用strip_native_libs下的so。
 
 ![image](https://user-images.githubusercontent.com/13035820/184604882-d6e19a82-56bf-49c5-8e0e-36cd05a8a661.png)

 

&emsp;&emsp;项目会包含有调试与无调试信息的两个版本 so。通常一次编译会先生成一个有含有调试信息的 so，再通过对这些含有调试信息的 so 进行一次 strip  产生对应的无调试信息 so，发布产品都是用这些 strip 后的 so。

&emsp;&emsp;一般的分析崩溃日志的工具都是利用含有调试信息的 so， 结合崩溃信息，分析崩溃点在源代码中的行号。


<br/>
<h5>使用教程</h5>
1 项目依赖插件：

![image](https://user-images.githubusercontent.com/13035820/184600616-a081fb85-9f5a-4696-9b53-dbac67b17ecc.png)


2 使用教程：

（1）dmp文件转换

![image](https://user-images.githubusercontent.com/13035820/184600934-9f43d284-0279-4b68-bac1-eeecb44c1dc3.png)


（2）addr2line地址转换

![image](https://user-images.githubusercontent.com/13035820/184601021-18e01e4d-2b6b-4db3-a2bd-0eb4c9f76a9b.png)


（3）ndk-stack定位

![image](https://user-images.githubusercontent.com/13035820/184601073-66af3d5c-7bf1-47c9-b6f4-c1e6a123b432.png)




