1. String是Java语言非常基础和重要的类，提供了构造和管理字符串的各种基本逻辑。它是典型的Immutable类，被声明成为final class，所有属性也都是final的。也由于它的不可变性，类似拼接、裁剪字符串等动作，都会产生新的String对象。由于字符串操作的普遍性，所以相关操作的效率往往对应用性能有明显影响。
2. StringBuffer是为解决上面提到拼接产生太多中间对象的问题而提供的一个类，我们可以用append或者add方法，把字符串添加到已有序列的末尾或者指定位置。StringBuffer本质是一个线程安全的可修改字符序列，它保证了线程安全，也随之带来了额外的性能开销，所以除非有线程安全的需要，不然还是推荐使用它的后继者，也就是StringBuilder。
3. StringBuilder是Java 1.5中新增的，在能力上和StringBuffer没有本质区别，但是它去掉了线程安全的部分，有效减小了开销，是绝大部分情况下进行字符串拼接的首选。
4. StringBuffer和StringBuilder底层都是利用可修改的（char，JDK 9以后是byte）数组，二者都继承了AbstractStringBuilder，里面包含了基本操作，区别仅在于最终的方法是否加了synchronized。

## 那为什么我们需要一个不可变的String呢
1. 当我们需要一个字符串时，我们可能大量用到这同一个字符串比如"abc"，当我们第二次去String var = "abc"时，拿到的是字符串常量池中的同一个String对象（这就是不可变的真正原因），这个时候就能避免再去申请一份空间存储重复值（享元模式）。
2. 字符串对象不可变，这意味着它里面的hashCode不会随意变换（缓存了hashCode），能够被多次复用，不用每次都去计算hashCode

## JDK9中String实现方式的改变
private final byte[] value;
String是由byte类型的数组来进行存储的

## oops 延伸考点
通过String和相关类，考察基本的线程安全设计与实现，各种基础编程实践。
考察JVM对象缓存机制的理解以及如何良好地使用。
考察JVM优化Java代码的一些技巧。
String相关类的演进，比如Java 9中实现的巨大变化。
…

