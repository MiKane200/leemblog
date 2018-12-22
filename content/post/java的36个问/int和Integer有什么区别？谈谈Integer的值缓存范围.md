## 回答
1. int是我们常说的整形数字，是Java的8个原始数据类型（Primitive Types，boolean、byte 、short、char、int、float、double、long）之一。Java语言虽然号称一切都是对象，但原始数据类型是例外。
2. Integer是int对应的包装类，它有一个int类型的字段存储数据，并且提供了基本操作，比如数学运算、int和字符串之间转换等。在Java 5中，引入了自动装箱和自动拆箱功能（boxing/unboxing），Java可以根据上下文，自动进行转换，极大地简化了相关编程。
3. 关于Integer的值缓存，这涉及Java 5中另一个改进。构建Integer对象的传统方式是直接调用构造器，直接new一个对象。但是根据实践，我们发现大部分数据操作都是集中在有限的、较小的数值范围，因而，在Java 5中新增了静态工厂方法valueOf，在调用它的时候会利用一个缓存机制，带来了明显的性能改进。按照Javadoc，这个值默认缓存是-128到127之间。
- Boolean，缓存了true/false对应实例，确切说，只会返回两个常量实例Boolean.TRUE/FALSE。
- Short，同样是缓存了-128到127之间的数值。
- Byte，数值有限，所以全部都被缓存。
- Character，缓存范围'\u0000' 到 '\u007F'。

## 引申问题
编译阶段、运行时，自动装箱/自动拆箱是发生在什么阶段？
我在前面提到使用静态工厂方法valueOf会使用到缓存机制，那么自动装箱的时候，缓存机制起作用吗？
为什么我们需要原始数据类型，Java的对象似乎也很高效，应用中具体会产生哪些差异？
阅读过Integer源码吗？分析下类或某些方法的设计要点。

## 自动装箱、拆箱
自动装箱实际上算是一种语法糖。什么是语法糖？可以简单理解为Java平台为我们自动进行了一些转换，保证不同的写法在运行时等价，它们发生在编译阶段，也就是生成的字节码是一致的。
像前面提到的整数，javac替我们自动把装箱转换为Integer.valueOf()，把拆箱替换为Integer.intValue()，这似乎这也顺道回答了另一个问题，既然调用的是Integer.valueOf，自然能够得到缓存的好处啊。

## 引发的问题探究 -- 自动装箱/自动拆箱似乎很酷，在编程实践中，有什么需要注意的吗？
1. 原则上，建议避免无意中的装箱、拆箱行为，尤其是在性能敏感的场合，创建10万个Java对象和10万个整数的开销可不是一个数量级的，不管是内存使用还是处理速度，光是对象头的空间占用就已经是数量级的差距了。
2. 我们其实可以把这个观点扩展开，使用原始数据类型、数组甚至本地代码实现等，在性能极度敏感的场景往往具有比较大的优势，用其替换掉包装类、动态数组（如ArrayList）等可以作为性能优化的备选项。一些追求极致性能的产品或者类库，会极力避免创建过多对象。当然，在大多数产品代码里，并没有必要这么做，还是以开发效率优先。以我们经常会使用到的计数器实现为例，下面是一个常见的线程安全计数器实现。
```java
class Counter {
    private final AtomicLong counter = new AtomicLong();  
    public void increase() {
        counter.incrementAndGet();
    }
}
//如果利用原始数据类型，可以将其修改为
class CompactCounter {
    private volatile long counter;
    private static final AtomicLongFieldUpdater<CompactCounter> updater = AtomicLongFieldUpdater.newUpdater(CompactCounter.class, "counter");
    public void increase() {
        updater.incrementAndGet(this);
    }
}
```

## 数据类型对应用移植会产生影响吗？
不同环境，原始数据类型是不存在差异的，这些明确定义在Java语言规范里面，不管是32位还是64位环境，开发者无需担心数据的位数差异。
对于应用移植，虽然存在一些底层实现的差异，比如64位HotSpot JVM里的对象要比32位HotSpot JVM大（具体区别取决于不同JVM实现的选择），但是总体来说，并没有行为差异，应用移植还是可以做到宣称的“一次书写，到处执行”，应用开发者更多需要考虑的是容量、能力等方面的差异。