## Docker并不是一种完全的虚拟化技术，而更是一种轻量级的隔离技术
[img](../../../static/img/Docker与虚拟机区别.png)
1. 从技术角度，基于namespace，Docker为每个容器提供了单独的命名空间，对网络、PID、用户、IPC通信、文件系统挂载点等实现了隔离。对于CPU、内存、磁盘IO等计算资源，则是通过CGroup进行管理。

## 从JVM运行机制的角度，为什么这些“沟通障碍”会导致OOM等问题呢？
这个问题实际是反映了JVM如何根据系统资源（内存、CPU等）情况，在启动时设置默认参数。这就是所谓的Ergonomics机制，例如：
1. JVM会大概根据检测到的内存大小，设置最初启动时的堆大小为系统内存的1/64；并将堆最大值，设置为系统内存的1/4。
2. 而JVM检测到系统的CPU核数，则直接影响到了Parallel GC的并行线程数目和JIT complier线程数目，甚至是我们应用中ForkJoinPool等机制的并行等级。
3. 这些默认参数，是根据通用场景选择的初始值。但是由于容器环境的差异，Java的判断很可能是基于错误信息而做出的。这就类似，我以为我住的是整栋别墅，实际上却只有一个房间是给我住的。

## 如果你能够升级到最新的JDK版本，这个问题就迎刃而解了
首先，如果你能够升级到最新的JDK版本，这个问题就迎刃而解了。
1. 针对这种情况，JDK 9中引入了一些实验性的参数，以方便Docker和Java“沟通”，例如针对内存限制，可以使用下面的参数设置：
    1. -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap 这两个参数是顺序敏感的
2. 如果你可以切换到JDK 10或者更新的版本，问题就更加简单了。Java对容器（Docker）的支持已经比较完善，默认就会自适应各种资源限制和实现差异。前面提到的实验性参数“UseCGroupMemoryLimitForHeap”已经被标记为废弃。
3. JDK 9中的实验性改进已经被移植到Oracle JDK 8u131之中，你可以直接下载相应镜像，并配置“UseCGroupMemoryLimitForHeap”，后续很有可能还会进一步将JDK 10中相关的增强，应用到JDK 8最新的更新中。
4. 如果我暂时只能使用老版本的JDK怎么办？
    1. 明确设置堆、元数据区等内存区域大小，保证Java进程的总大小可控。
    2. 例如，我们可能在环境中，这样限制容器内存：`docker run -it --rm --name yourcontainer -p 8080:8080 -m 800M repo/your-java-container:openjdk`
    3. 那么，就可以额外配置下面的环境变量，直接指定JVM堆大小。`-e JAVA_OPTIONS='-Xmx300m'`
    4. 明确配置GC和JIT并行线程数目，以避免二者占用过多计算资源。`-XX:ParallelGCThreads -XX:CICompilerCount`