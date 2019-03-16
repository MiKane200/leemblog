## Happen-before
1. Happen-before关系，是Java内存模型中保证多线程操作可见性的机制，也是对早期语言规范中含糊的可见性概念的一个精确定义。
2. 它是Java内存模型中定义的两项操作之间的偏序关系，如果操作A先行发生于操作B，其意思就是说，在发生操作B之前，操作A产生的影响都能被操作B观察到，“影响”包括修改了内存中共享变量的值、发送了消息、调用了方法等，它与时间上的先后发生基本没有太大关系。这个原则特别重要，它是判断数据是否存在竞争、线程是否安全的主要依据。
#### 它的具体表现形式，包括但远不止是我们直觉中的synchronized、volatile、lock操作顺序等方面，例如：
1. 线程内执行的每个操作，都保证happen-before后面的操作，这就保证了基本的程序顺序规则，这是开发者在书写程序时的基本约定。
2. 对于volatile变量，对它的写操作，保证happen-before在随后对该变量的读取操作。
3. 对于一个锁的解锁操作，保证happen-before加锁操作。
4. 对象构建完成，保证happen-before于finalizer的开始动作。
5. 甚至是类似线程内部操作的完成，保证happen-before其他Thread.join()的线程等。
6. 这些happen-before关系是存在着传递性的，如果满足a happen-before b和b happen-before c，那么a happen-before c也成立。
* 前面我一直用happen-before，而不是简单说前后，是因为它不仅仅是对执行时间的保证，也包括对内存读、写操作顺序的保证。仅仅是时钟顺序上的先后，并不能保证线程交互的可见性。

## 为什么需要JMM，它试图解决什么问题？ JMM是如何解决可见性等各种问题的？类似volatile，体现在具体用例中有什么效果？
#### 原因：
1. 既不能保证一些多线程程序的正确性，例如最著名的就是双检锁（Double-Checked Locking，DCL）的失效问题，具体在对单例模式的说明中，双检锁可能导致未完整初始化的对象被访问，理论上这叫并发编程中的安全发布（Safe Publication）失败。即 => 当线程A执行到" instance = new singleton();"这一行，而线程B执行到外层"if (instance == null) "时，可能出现instance还未完成构造，但是此时不为null导致线程B获取到一个不完整的instance。
2. 也不能保证同一段程序在不同的处理器架构上表现一致，例如有的处理器支持缓存一致性，有的不支持，各自都有自己的内存排序模型。
3. 所以，Java迫切需要一个完善的JMM，能够让普通Java开发者和编译器、JVM工程师，能够清晰地达成共识。换句话说，可以相对简单并准确地判断出，多线程程序什么样的执行序列是符合规范的。

#### JMM解决可见性
如果处理器对某个共享变量进行了修改，可能只是体现在该内核的缓存里，这是个本地状态，而运行在其他内核上的线程，可能还是加载的旧状态，这很可能导致一致性的问题。从理论上来说，多线程共享引入了复杂的数据依赖性，不管编译器、处理器怎么做重排序，都必须尊重数据依赖性的要求，否则就打破了正确性！这就是JMM所要解决的问题。
[img](../../../static/img/JVM运行时内存区与物理结构.png)

#### JMM内部的实现
其是依赖于所谓的内存屏障，通过禁止某些重排序的方式，提供内存可见性保证，也就是实现了各种happen-before规则。与此同时，更多复杂度在于，需要尽量确保各种编译器、各种体系结构的处理器，都能够提供一致的行为。

* 以volatile为例，看看如何利用内存屏障实现JMM定义的可见性？
    1. 对该变量的写操作之后，编译器会插入一个写屏障。
    2. 对该变量的读操作之前，编译器会插入一个读屏障。
    3. 内存屏障能够在类似变量读、写操作之后，保证其他线程对volatile变量的修改对当前线程可见，或者本地修改对其他线程提供可见性。换句话说，线程写入，写屏障会通过类似强迫刷出处理器缓存的方式，让其他线程能够拿到最新数值
    4. 内存屏障只是解决了顺序一致性问题，不解决缓存一致性问题，缓存一致性是由cpu的缓存锁以及MESI协议来 完成的。而缓存一致性协议只关心缓存一致性，不关心顺序一致性。

## 从应用开发者的角度，JMM提供的可见性，体现在类似volatile上，具体行为是什么样呢？

#### 先看代码，希望达到的效果是，当condition被赋值为false时，线程A能够从循环中退出。
1. 这里就需要condition被定义为volatile变量，不然其数值变化，往往并不能被线程A感知，进而无法退出。当然，也可以在while中，添加能够直接或间接起到类似效果的代码。
```java
// Thread A
while (condition) {
}

// Thread B
condition = false;
```

2. 第二，举Brian Goetz提供的一个经典用例，使用volatile作为守卫对象，实现某种程度上轻量级的同步
```java
Map configOptions;
char[] configText;
volatile boolean initialized = false;

// Thread A
configOptions = new HashMap();
configText = readConfigFile(fileName);
processConfigOptions(configText, configOptions);
initialized = true;

// Thread B
while (!initialized)
  sleep();
// use configOptions
```
* JSR-133重新定义的JMM模型，能够保证线程B获取的configOptions是更新后的数值。
    1. 也就是说volatile变量的可见性发生了增强，能够起到守护其上下文的作用。线程A对volatile变量的赋值，会强制将该变量自己和当时其他变量的状态都刷出缓存，为线程B提供可见性。当然，这也是以一定的性能开销作为代价的，但毕竟带来了更加简单的多线程行为。
    2. 经常会说volatile比synchronized之类更加轻量，但轻量也仅仅是相对的，volatile的读、写仍然要比普通的读写要开销更大，所以如果你是在性能高度敏感的场景，除非你确定需要它的语义，不然慎用。

## 总结
从happen-before关系开始，理解了什么是Java内存模型。阐述了问题的由来，以及JMM是如何通过类似内存屏障等技术实现的。最后，以volatile为例，分析了可见性在多线程场景中的典型用例。