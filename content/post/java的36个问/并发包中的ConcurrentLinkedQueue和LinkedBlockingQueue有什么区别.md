## 概括回答
Concurrent类型基于lock-free，在常见的多线程访问场景，一般可以提供较高吞吐量。
而LinkedBlockingQueue内部则是基于锁，并提供了BlockingQueue的等待性方法。

不知道你有没有注意到，java.util.concurrent包提供的容器（Queue、List、Set）、Map，从命名上可以大概区分为Concurrent*、CopyOnWrite和Blocking等三类，同样是线程安全容器，可以简单认为：
1. Concurrent类型没有类似CopyOnWrite之类容器相对较重的修改开销。
2. 但是，凡事都是有代价的，Concurrent往往提供了较低的遍历一致性。你可以这样理解所谓的弱一致性，例如，当利用迭代器遍历时，如果容器发生修改，迭代器仍然可以继续进行遍历。
3. 与弱一致性对应的，就是我介绍过的同步容器常见的行为“fail-fast”，也就是检测到容器在遍历过程中发生了修改，则抛出ConcurrentModificationException，不再继续遍历。
4. 弱一致性的另外一个体现是，size等操作准确性是有限的，未必是100%准确。
5. 与此同时，读取的性能具有一定的不确定性。

## 附加问题考察
1. 哪些队列是有界的，哪些是无界的？（很多同学反馈了这个问题）
2. 针对特定场景需求，如何选择合适的队列实现？
3. 从源码的角度，常见的线程安全队列是如何实现的，并进行了哪些改进以提高性能表现？

## 在日常的应用开发中，如何进行选择呢？以LinkedBlockingQueue、ArrayBlockingQueue和SynchronousQueue为例，我们一起来分析一下，根据需求可以从很多方面考量：

1. 考虑应用场景中对队列边界的要求。ArrayBlockingQueue是有明确的容量限制的，而LinkedBlockingQueue则取决于我们是否在创建时指定，SynchronousQueue则干脆不能缓存任何元素。
2. 从空间利用角度，数组结构的ArrayBlockingQueue要比LinkedBlockingQueue紧凑，因为其不需要创建所谓节点，但是其初始分配阶段就需要一段连续的空间，所以初始内存需求更大。
3. 通用场景中，LinkedBlockingQueue的吞吐量一般优于ArrayBlockingQueue，因为它实现了更加细粒度的锁操作。ArrayBlockingQueue实现比较简单，性能更好预测，属于表现稳定的“选手”。
4. 如果我们需要实现的是两个线程之间接力性（handoff）的场景，按照专栏上一讲的例子，你可能会选择CountDownLatch，但是SynchronousQueue也是完美符合这种场景的，而且线程间协调和数据传输统一起来，代码更加规范。
5. 可能令人意外的是，很多时候SynchronousQueue的性能表现，往往大大超过其他实现，尤其是在队列元素较小的场景。